import { task } from "hardhat/config";

// npx hardhat deploy-aggregator --network omni_testnet

task("deploy-aggregator", "Deploys a aggregator contract").setAction(
    async (args, hre, runSuper) => {
        const {
            ethers,
            getNamedAccounts,
            deployments: { deploy, getOrNull, all },
        } = hre;

        const { deployer } = await getNamedAccounts();

        const aggregatorDeploy = await deploy("CallAggregator", {
            from: deployer,
            log: true,
            contract: "contracts/CallAggregator.sol:CallAggregator",
            args: [],
        });
    }
);