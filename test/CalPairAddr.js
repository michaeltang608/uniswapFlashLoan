const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");

describe('calPairAddr', () => {
    async function deploy() {
        const Contract = await ethers.getContractFactory("CalPairAddr");
        const instance = await Contract.deploy();
        return { instance };
    }

    describe('module1', () => {
        it('testCalPairAddr', async () => {
            const { instance } = await loadFixture(deploy);
            let token0 = '0xdAC17F958D2ee523a2206206994597C13D831ec7'
            let token1 = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2'
            let small, big
            token0 = '0x' + token0.substring(2).toUpperCase()
            token1 = '0x' + token1.substring(2).toUpperCase()
            if (token0 > token1) {
                big = token0
                small = token1
            } else {
                big = token1
                small = token0
            }
            let result = await instance.cal(small, big);
            console.log(`pair addr = ${result}`)

        })
    })
})