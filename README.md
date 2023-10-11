# Sample Uniswap flash loan Project

This project demonstrates a basic uniswap flash loan use case. It comes with a sample flash loan contract, a script for deploying and testing that contract. 

## Prerequisites

Before running this project, we assume that you already have basic understanding of the following tech stack: npm, solidity, hardhat, uniswap protocol. Please make sure that these software framework is already installed before proceeding.

## Procedure to follow
1 start local ganache by fork the Ethereum main net.
```shell
ganache -f https://eth-mainnet.alchemyapi.io/v2/YOUR_API_KEY --deterministic
```
Replace private keys in config/index.js with your's that is displayed in ganache console
2 install node packages
```shell
npm i
```
3 run scripts
```
npx hardhat run scripts/flashLoan.js
```
As hardhat test function does not support non native hardhat blockchain node, we can only demonstrate the function under scripts folder.
