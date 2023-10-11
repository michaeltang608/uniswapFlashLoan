// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract CalPairAddr {
    event PairAddr(address pairAddr);

    function cal(address token0, address token1) public pure returns (address) {
        address factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
        address pair = address(
            uint160(
                uint(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f"
                        )
                    )
                )
            )
        );
        return pair;
    }
}
