const hre = require("hardhat");
const fs = require("fs");
import "dotenv/config";
import { ethers } from "hardhat";
import { deploy } from "./utils/contract";
import { outputs } from "./output";
import { writeOutput } from "./utils/write_output";
const { utils } = ethers;

const { FEE_TO, FEE_TO_SETTER, NETWORK = "local" } = process.env;

export const main = async () => {
  const [owner] = await ethers.getSigners();

  if (NETWORK !== "local" && NETWORK !== "testnet" && NETWORK !== "mainnet") {
    throw new Error("NETWORK is invalid");
  }

  if (!FEE_TO || !FEE_TO_SETTER) {
    throw new Error("FEE_TO and FEE_TO_SETTER must be provided in .env file");
  }

  if (!utils.isAddress(FEE_TO) || !utils.isAddress(FEE_TO_SETTER)) {
    throw new Error("FEE_TO and FEE_TO_SETTER must be provided in .env file");
  }

  const network = await ethers.provider.getNetwork();
  console.log("Deploying on chain ID:", network.chainId);

  const ownerBalance = await owner.getBalance();
  console.log(
    `Deployer ${owner.address} has balance: ${utils.formatEther(ownerBalance)}`
  );

  console.log();
  console.log("Deploying Factory contract with params:");
  console.log("+ feeToSetter:", FEE_TO_SETTER);
  const factory = await deploy("GEXFactory", { args: [FEE_TO_SETTER] });
  console.log("Factory deployed at:", factory.address);

  console.log();
  console.log("Setting feeTo...");
  console.log("+ feeTo:", FEE_TO);
  let txid = await (
    await factory.setFeeTo(FEE_TO, { from: owner.address })
  ).wait();
  console.log("Set feeTo at:", txid.transactionHash);

  console.log();
  const initCode = await factory.INIT_CODE_PAIR_HASH.call();
  console.log(
    "NOTE: You must replace the default INIT_CODE_PAIR_HASH and re-compile before deploying the GEXRouter contract."
  );
  console.log(
    `Copy ${initCode.replace(
      "0x",
      ""
    )} to line 38 in contracts/libraries/GEXLibrary.sol file`
  );
  console.log("Then, run: npx run compile");

  outputs[NETWORK].GEXFactory.address = factory.address;
  outputs[NETWORK].GEXFactory.vars.INIT_CODE_PAIR_HASH = initCode;
  outputs[NETWORK].GEXFactory.vars.feeTo = FEE_TO;
  outputs[NETWORK].GEXFactory.vars.feeToSetter = FEE_TO_SETTER;

  writeOutput(NETWORK, outputs[NETWORK]);
  console.log("DONE");
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
