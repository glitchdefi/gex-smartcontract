import { BigNumber, ContractReceipt } from "ethers";
import { ethers, network } from "hardhat";

export const currentTimestamp = async (): Promise<BigNumber> => {
  const { timestamp } = await network.provider.send("eth_getBlockByNumber", [
    "latest",
    true,
  ]);
  return BigNumber.from(timestamp);
};

export const currentWeekTimestamp = async (): Promise<BigNumber> => {
  return (await currentTimestamp()).div(WEEK).mul(WEEK);
};

export const fromNow = async (seconds: number): Promise<BigNumber> => {
  const now = await currentTimestamp();
  return now.add(seconds);
};

export const advanceTime = async (seconds: number): Promise<void> => {
  await ethers.provider.send("evm_increaseTime", [
    parseInt(seconds.toString()),
  ]);
  await ethers.provider.send("evm_mine", []);
};

export const advanceToTimestamp = async (timestamp: number): Promise<void> => {
  await setNextBlockTimestamp(timestamp);
  await ethers.provider.send("evm_mine", []);
};

export const setNextBlockTimestamp = async (
  timestamp: number
): Promise<void> => {
  await ethers.provider.send("evm_setNextBlockTimestamp", [
    parseInt(timestamp.toString()),
  ]);
};

export const lastBlockNumber = async (): Promise<number> =>
  Number(await network.provider.send("eth_blockNumber"));

export const receiptTimestamp = async (
  receipt: ContractReceipt | Promise<ContractReceipt>
): Promise<number> => {
  const blockHash = (await receipt).blockHash;
  const block = await ethers.provider.getBlock(blockHash);
  return block.timestamp;
};

export const SECOND = 1;
export const MINUTE = SECOND * 60;
export const HOUR = MINUTE * 60;
export const DAY = HOUR * 24;
export const WEEK = DAY * 7;
export const MONTH = DAY * 30;
