const hre = require("hardhat");
import "dotenv/config";
import { ethers } from "hardhat";
import { deploy } from "./utils/contract";
import { outputs } from "./output";
import { writeOutput } from "./utils/write_output";
const { utils } = ethers;
const { NETWORK } = process.env;

export const main = async () => {
  const [owner] = await ethers.getSigners();

  if (NETWORK !== "local" && NETWORK !== "testnet" && NETWORK !== "mainnet") {
    throw new Error("NETWORK is invalid");
  }

  const network = await ethers.provider.getNetwork();
  console.log("Deploying on chain ID:", network.chainId);

  const ownerBalance = await owner.getBalance();
  console.log(
    `Deployer ${owner.address} has balance: ${utils.formatEther(ownerBalance)}`
  );

  console.log();
  console.log("wGLCH deploying...");
  const wGLCH = await deploy("WGLCH", { from: owner });
  console.log("wGLCH deployed at:", wGLCH.address);

  console.log();
  console.log("GEXRouter01 deploying...");
  const router = await deploy("GEXRouter01", {
    from: owner,
    args: [outputs[NETWORK].GEXFactory.address, wGLCH.address],
  });
  console.log("GEXRouter01 deployed at:", router.address);

  console.log();
  console.log("Multicall deploying...");
  const multicall = await deploy("Multicall", { from: owner });
  console.log("Multicall deployed at:", multicall.address);

  outputs[NETWORK].Multicall.address = multicall.address;
  outputs[NETWORK].GEXRouter01.address = router.address;
  outputs[NETWORK].GEXRouter01.vars.WGLCH = wGLCH.address;
  outputs[NETWORK].GEXRouter01.vars.factory =
    outputs[NETWORK].GEXFactory.address;

  writeOutput(NETWORK, outputs[NETWORK]);
  console.log("DONE");
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
