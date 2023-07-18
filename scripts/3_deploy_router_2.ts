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
  console.log("GEXRouter01 deploying...");
  const router = await deploy("GEXRouter02", {
    from: owner,
    args: ["0xcBE8B5fb7145767c3D2519f2463DAFa2d8f48d5E", "0x5BB81754B95D73f918896CBFCF54B1050d6F7607"],
  });
  console.log("GEXRouter02 deployed at:", router.address);

};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
