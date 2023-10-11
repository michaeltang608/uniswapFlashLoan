// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint amount) external returns (bool);

    function withdraw(uint amount) external;
}

interface IUniswapV2Pair {
    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;
}

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

contract MyFlashLoan {
    // common address
    address public router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public USDTETH = 0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852;
    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    //define an event, for the purpose of debug and record
    event BalanceLog(uint256 amount, string comment);

    uint256 ETHAmount;
    uint256 LoanAmount;

    constructor() {
        _safeApprove(USDC);
        _safeApprove(USDT);
        _safeApprove(WETH);
    }

    //deposit eth for weth
    function deposit() public payable {
        ETHAmount = msg.value;
        IWETH(WETH).deposit{value: ETHAmount}();
        //query WETH balance and emit log
        uint wethBalance = IERC20(WETH).balanceOf(address(this));
        emit BalanceLog(wethBalance, "myFlashLoan weth amount");
    }

    //query ERC20 token balance
    function queryTokenBalance(
        address token,
        address owner
    ) public view returns (uint256) {
        return IERC20(token).balanceOf(owner);
    }

    //exec flash loan
    function flashLoan(uint256 _loanAmount) public {
        /**
        borrow only usdt
        amount0: weth amount
        amount1: usdt amount
         */
        LoanAmount = _loanAmount;
        bytes memory _data = bytes("flashLoan");
        IUniswapV2Pair(USDTETH).swap(
            uint(0),
            _loanAmount,
            address(this),
            _data
        );
    }

    //callback, do whatever u what
    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external {
        /**
        main logic:
        1 swap borrowed usdt for usdc
        2 swap usdc for weth
        3 cal precise weth amount needed to pay back borrowed usdt
        4 repay loan with weth
         */
        // query usdt balance
        uint256 wethBalance = queryTokenBalance(WETH, address(this));
        uint256 usdtBalance = queryTokenBalance(USDT, address(this));
        emit BalanceLog(wethBalance, "initial weth balance of this contract");
        emit BalanceLog(usdtBalance, "initial usdt balance of this contract");

        // step1 usdt-usdc
        address[] memory PATH_USDT_USDC = new address[](2);
        PATH_USDT_USDC[0] = USDT;
        PATH_USDT_USDC[1] = USDC;

        uint[] memory amountsOut = IUniswapV2Router(router)
            .swapExactTokensForTokens(
                usdtBalance,
                uint(0),
                PATH_USDT_USDC,
                address(this),
                block.timestamp + 1800
            );

        emit BalanceLog(amountsOut[0], "usdt for usdc, usdt val");
        emit BalanceLog(amountsOut[1], "usdt for usdc, usdc val");

        // step2 usdc-weth
        address[] memory PATH_USDC_WETH = new address[](2);
        PATH_USDC_WETH[0] = USDC;
        PATH_USDC_WETH[1] = WETH;

        uint[] memory amountsOut1 = IUniswapV2Router(router)
            .swapExactTokensForTokens(
                amountsOut[1],
                uint(0),
                PATH_USDC_WETH,
                address(this),
                block.timestamp + 1800
            );

        emit BalanceLog(amountsOut1[0], "usdc for weth, usdc val");
        emit BalanceLog(amountsOut1[1], "usdc for weth, weth val");

        //cal min weth needed to repay borrowed usdt
        address[] memory PATH_WETH_USDT = new address[](2);
        PATH_WETH_USDT[0] = WETH;
        PATH_WETH_USDT[1] = USDT;
        uint[] memory amountsOut3 = IUniswapV2Router(router).getAmountsIn(
            LoanAmount,
            PATH_WETH_USDT
        );
        emit BalanceLog(amountsOut3[0], "weth needed to repay loan");
        // repaly
        IERC20(WETH).transfer(USDTETH, amountsOut3[0]);

        emit BalanceLog(wethBalance - amountsOut3[0], "left weth");
    }

    function _safeApprove(address token) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, router, 2 ** 256 - 1)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }
}
