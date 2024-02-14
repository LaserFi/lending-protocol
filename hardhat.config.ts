import * as dotenv from "dotenv";
dotenv.config();

import "@nomicfoundation/hardhat-network-helpers";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-waffle";
import "@openzeppelin/hardhat-upgrades";
import "@typechain/hardhat";
import "hardhat-deploy";
import "hardhat-deploy-ethers";
import { HardhatUserConfig } from "hardhat/config";
import "solidity-coverage";

import "./tasks";

/** @type import('hardhat/config').HardhatUserConfig */
const config: HardhatUserConfig = {
    etherscan: {
        apiKey: {
          blast_sepolia: "blast_sepolia", // apiKey is not required, just set a placeholder
        },
        customChains: [
          {
            network: "blast_sepolia",
            chainId: 168587773,
            urls: {
              apiURL: "https://api.routescan.io/v2/network/testnet/evm/168587773/etherscan",
              browserURL: "https://testnet.blastscan.io"
            }
          }
        ]
      },
    networks: {
        blast_sepolia: {
            url: process.env.BLAST_RPC_URL!,
            //ovm: true,
            accounts: [process.env.BLAST_DEPLOYER_KEY!],
        },
        hardhat: {
            forking: {
                enabled: true,
                url: process.env.BLAST_RPC_URL!,
            },
            companionNetworks: {
                mainnet: "blast_sepolia",
            },
            autoImpersonate: true
        },
    },
    solidity: {
        compilers: [
            {
                version: "0.5.16",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
            {
                version: "0.6.12",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
            {
                version: "0.8.10",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        ],
    },
    namedAccounts: {
        deployer: 0,
    },
};

export default config;
