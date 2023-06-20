import { HardhatUserConfig } from "hardhat/config";
import "ethereum-waffle";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-waffle";
import "dotenv/config";

const { RPC_TESTNET, RPC_MAINNET, PRIVATE_KEY } = process.env;

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    testnet: {
      url: RPC_TESTNET,
      accounts: [PRIVATE_KEY!],
    },
    mainnet: {
      url: RPC_MAINNET,
      accounts: [PRIVATE_KEY!],
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.4",
        settings: {
          optimizer: {
            enabled: true,
            runs: 99999,
          },
        },
      },
      {
        version: "0.6.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 99999,
          },
        },
      },
      {
        version: "0.5.16",
        settings: {
          optimizer: {
            enabled: true,
            runs: 99999,
          },
        },
      },
      {
        version: "0.4.18",
        settings: {
          optimizer: {
            enabled: true,
            runs: 99999,
          },
        },
      },
    ],
  },
};

export default config;
