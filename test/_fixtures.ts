import { deployments, ethers } from "hardhat";

const setupFixture = deployments.createFixture(
    async ({ deployments, companionNetworks }, options) => {

        await deployments.fixture(undefined, {

            keepExistingDeployments: true,
        });
        
        const companionDeployments = companionNetworks["mainnet"].deployments;

        const [deployer] = await ethers.getSigners();
        
        const comptrollerDeploy = await deployments.deploy("Comptroller", {
            from: deployer.address,
            log: true,
            contract: "contracts/Comptroller.sol:Comptroller",
        });
        
        const unitrollerDeploy = await companionDeployments.get(
            "Comptroller",
        );
        const unitroller = await ethers.getContractAt(
            "Unitroller",
            unitrollerDeploy.address,
        );
        // set storage to new comptroller deploy
        await ethers.provider.send("hardhat_setStorageAt", [
            unitrollerDeploy.address,
            "0x2",
            ethers.utils.hexZeroPad(comptrollerDeploy.address, 32),
        ]);

        const comptroller = await ethers.getContractAt(
            "Comptroller",
            unitrollerDeploy.address,
        );
        console.log("here0")



        const rewardDistributorDeploy = await deployments.deploy(
            "RewardDistributor",
            {
                from: deployer.address,
                args: [],
                proxy: {
                    proxyContract: "OpenZeppelinTransparentProxy",
                    execute: {
                        init: {
                            methodName: "initialize",
                            args: [unitrollerDeploy.address],
                        },
                    },
                },
                log: true,
                contract:
                    "contracts/ExternalRewardDistributor.sol:ExternalRewardDistributor",
            },
        );
        const rewardDistributor = await ethers.getContractAt(
            "ExternalRewardDistributor",
            rewardDistributorDeploy.address,
        );
        console.log("here1")
        // read markets from comptroller and create contracts
        const markets = await comptroller.getAllMarkets();
        const cTokens = {};
        for (let i = 0; i < markets.length; i++) {
            const market = markets[i];
            const cToken = await ethers.getContractAt("CToken", market);
            const symbol = await cToken.symbol();
            cTokens[symbol] = cToken;
        }
        console.log("here2")
        return {
            comptroller,
            rewardDistributor,
            cTokens,
        };
    },
);

export { setupFixture };
