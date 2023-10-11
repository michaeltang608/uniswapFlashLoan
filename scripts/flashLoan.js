const { ethers } = require("hardhat")

const main = async () => {

    //deploy contract
    const Contract = await ethers.getContractFactory("MyFlashLoan");
    const instance = await Contract.deploy();
    await instance.deployed();
    console.log(
        `contract deployed to ${instance.address}`
    );

    // deposit 0.01 first for gas swap fee attrition
    const tx = instance.deposit({ value: ethers.utils.parseEther('1') });
    await (await tx).wait()

    const WETH = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2';
    const wethBalanceBeforeFlashLoan = await instance.queryTokenBalance(WETH, instance.address)
    console.log(`wethBalanceBeforeFlashLoan : ${ethers.utils.formatEther(wethBalanceBeforeFlashLoan)}`)

    // flashLoani
    const txFlashLoan = instance.flashLoan(ethers.utils.parseUnits('1000', 6), { gasLimit: 10 * 1000000 })
    txFlashLoan.then(txResp => {
        console.log('txFlashLoan send tx success')
        const receipt = txResp.wait()
        receipt
            .then(data => {
                console.log('receive successful receipt')
                const wethBalanceAfterFlashLoan = instance.queryTokenBalance(WETH, instance.address)
                wethBalanceAfterFlashLoan.then(data => {
                    console.log(`wethBalanceAfterFlashLoan : ${ethers.utils.formatEther(data)}`)
                })
            })
            .catch(e =>
                console.log(`receive failed receipt: ${e}`))

    }).catch(txErr => {
        console.log('txFlashLoan send tx fail', txErr)
    })

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});