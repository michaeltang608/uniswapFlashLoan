require("@nomicfoundation/hardhat-toolbox");

const { prvKeys, } = require('./config')


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {

    goerli: {
      url: 'https://eth-goerli.g.alchemy.com/v2/6Vy5IhTWK_mHpOz5hWp34DJ0OTxQ4g_X',
      accounts: [prvKeys[0],]
    },
    local: {
      url: 'http://127.0.0.1:8545',
      accounts: [prvKeys[0],]
    },
  }
};
