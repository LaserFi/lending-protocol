import { task } from "hardhat/config";

// npx hardhat deploy-unitroller --network omni_testnet

task("deploy-unitroller", "Deploys a unitroller contract").setAction(
    async (args, hre, runSuper) => {
        const {
            ethers,
            getNamedAccounts,
            deployments: { deploy, getOrNull, all },
        } = hre;

        const { deployer } = await getNamedAccounts();

        const unitrollerDeploy = await deploy("Unitroller", {
            from: deployer,
            log: true,
            contract: "contracts/Unitroller.sol:Unitroller",
            args: [],
        });
    }
);