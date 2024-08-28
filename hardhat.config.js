require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "local",
  chainId: 31337,
  solidity: {
    compilers: [
      {
        version: "0.8.8",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.4.24",
      },
      {
        version: "0.5.12",
      }
    ],
  },
  networks: {
    hardhat: {
      chainId: 31337,
      // allowBlocksWithSameTimestamp: true
    },
    local: {
      url: "http://127.0.0.1:8545",
      chainId: 31337,
      accounts: process.env.LOCAL_PRIVATE_KEY,
      gas: 30000000,
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  mocha: {
    timeout: 40000,
  },
};
