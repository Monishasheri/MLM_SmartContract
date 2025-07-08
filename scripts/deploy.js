const hre = require("hardhat");
require("dotenv").config();
async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contract with address account4:", deployer.address);
  const tokenAddress = process.env.TOKEN_ADDRESS;
  const MLM = await ethers.getContractFactory("MLM");
  const mlm = await MLM.connect(deployer).deploy(tokenAddress);
  await mlm.waitForDeployment();
  console.log("MLM contract deployed to", await mlm.getAddress());

  // const MyToken = await ethers.getContractFactory("MyToken");
  // const myToken = await MyToken.connect(deployer).deploy();
  // await myToken.waitForDeployment();
  // console.log("MLM contract deployed to", await myToken.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
