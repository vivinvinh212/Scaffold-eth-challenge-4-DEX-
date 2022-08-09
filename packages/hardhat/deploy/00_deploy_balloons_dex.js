// deploy/00_deploy_balloons_dex.js

const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("Balloons", {
    from: deployer,
    log: true,
  });

  const balloons = await ethers.getContract("Balloons", deployer);

  await deploy("DEX", {
    from: deployer,
    args: [balloons.address],
    log: true,
  });

  const dex = await ethers.getContract("DEX", deployer);

  // paste in your address here to get 10 balloons on deploy:
  await balloons.transfer("0x8921f75af8CC32333A9cFE94790f6a044a2A685d", (10 * 10 ** 18).toString());

  // paste in your address here to get 10 ethers on deploy:
  const signerDeployer = await ethers.provider.getSigner(deployer);
  const Txresult = await signerDeployer.sendTransaction({ to: "0x8921f75af8CC32333A9cFE94790f6a044a2A685d", value: ethers.utils.parseEther("10") });

  // uncomment to init DEX on deploy:
  // console.log(`Approving DEX (${dex.address}) to take Balloons from main account...`)
  // If you are going to the testnet make sure your deployer account has enough ETH
  await balloons.approve(dex.address, ethers.utils.parseEther('100'));
  console.log("INIT exchange...")
  await dex.init((3 * 10 ** 18).toString(), { value: ethers.utils.parseEther('3'), gasLimit: 200000 })
};
module.exports.tags = ["Balloons", "DEX"];
