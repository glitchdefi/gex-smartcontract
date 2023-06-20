import { ethers } from "hardhat";
import { Contract } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { deploy, deployedAt } from "../../scripts/utils/contract";
const { utils } = ethers;

interface FactoryFixture {
  factory: Contract;
}

export async function factoryFixture(
  signer: SignerWithAddress
): Promise<FactoryFixture> {
  const factory = await deploy("GEXFactory", { args: [signer.address] });
  return { factory };
}

interface PairFixture extends FactoryFixture {
  token0: Contract;
  token1: Contract;
  pair: Contract;
}

export async function pairFixture(
  signer: SignerWithAddress
): Promise<PairFixture> {
  const { factory } = await factoryFixture(signer);

  const tokenA = await deploy("MockERC20", {
    args: ["USDT", "USDT", utils.parseEther("1000000")],
  });

  const tokenB = await deploy("MockERC20", {
    args: ["ETH", "ETH", utils.parseEther("1000000")],
  });

  await (await factory.createPair(tokenA.address, tokenB.address)).wait();
  const pairAddress = await factory.getPair(tokenA.address, tokenB.address);

  const pair = await deployedAt("GEXPair", pairAddress);

  const token0Address = (await pair.token0()).address;
  const token0 = tokenA.address === token0Address ? tokenA : tokenB;
  const token1 = tokenA.address === token0Address ? tokenB : tokenA;

  return { factory, token0, token1, pair };
}
