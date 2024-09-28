require("@nomicfoundation/hardhat-ethers");
require('@nomicfoundation/hardhat-toolbox');
require("dotenv").config();

const { ALCHEMY_RPC_URL, PRIVATE_KEY } = process.env

module.exports = {
  solidity: "0.8.18",
  networks: {
    scroll: {
      url: process.env.ALCHEMY_RPC_URL,
      chainId: 534351,
      accounts: [process.env.PRIVATE_KEY],
    },
  }
} 