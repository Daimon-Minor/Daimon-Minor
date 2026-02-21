require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: { enabled: true, runs: 200 },
      viaIR: true,
    },
  },

  networks: {
    hardhat: {},
    localhost: { url: "http://127.0.0.1:8545" },

    // ── Base Testnet ────────────────────────────────────────────
    "base-sepolia": {
      url:      process.env.BASE_SEPOLIA_RPC || "https://sepolia.base.org",
      accounts: process.env.PRIVATE_KEY ? [`0x${process.env.PRIVATE_KEY}`] : [],
      chainId:  84532,
      gasPrice: "auto",
    },

    // ── Base Mainnet ────────────────────────────────────────────
    "base": {
      url:      process.env.BASE_MAINNET_RPC || "https://mainnet.base.org",
      accounts: process.env.PRIVATE_KEY ? [`0x${process.env.PRIVATE_KEY}`] : [],
      chainId:  8453,
      gasPrice: "auto",
    },

    // ── Ethereum (for DAIMON parent) ────────────────────────────
    "sepolia": {
      url:      process.env.ETH_SEPOLIA_RPC || "",
      accounts: process.env.PRIVATE_KEY ? [`0x${process.env.PRIVATE_KEY}`] : [],
      chainId:  11155111,
    },
  },

  etherscan: {
    apiKey: {
      base:         process.env.BASESCAN_API_KEY || "",
      "base-sepolia": process.env.BASESCAN_API_KEY || "",
      sepolia:      process.env.ETHERSCAN_API_KEY || "",
    },
    customChains: [
      {
        network: "base",
        chainId: 8453,
        urls: {
          apiURL:     "https://api.basescan.org/api",
          browserURL: "https://basescan.org",
        },
      },
      {
        network: "base-sepolia",
        chainId: 84532,
        urls: {
          apiURL:     "https://api-sepolia.basescan.org/api",
          browserURL: "https://sepolia.basescan.org",
        },
      },
    ],
  },

  gasReporter: {
    enabled:  process.env.REPORT_GAS !== undefined,
    currency: "USD",
    L2:       "base",
  },

  sourcify: {
    enabled: true,
  },
};
