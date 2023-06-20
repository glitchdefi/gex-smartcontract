import { ethers } from "hardhat";
import { Contract } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";

export type ContractDeploymentParams = {
  from?: SignerWithAddress;
  args?: Array<unknown>;
};

export async function deploy(
  contract: string,
  { from, args }: ContractDeploymentParams = {}
): Promise<Contract> {
  if (!args) args = [];
  if (!from) {
    from = (await ethers.getSigners())[0];
  }
  const ContractFactory = (await ethers.getContractFactory(contract)).connect(
    from
  );
  const instance = await ContractFactory.deploy(...args);
  await instance.deployed();
  return instance;
}

export async function deployWithProxy(
  contract: string,
  proxyAdmin: string,
  { from, args }: ContractDeploymentParams = {}
): Promise<Contract> {
  if (!args) args = [];
  if (!from) from = (await ethers.getSigners())[0];
  const ContractFactory = (await ethers.getContractFactory(contract)).connect(
    from
  );
  const logicInstance = await ContractFactory.deploy(...args);
  await logicInstance.deployed();

  const UpgradableProxy = await ethers.getContractFactory("UpgradableProxy");
  const proxy = await UpgradableProxy.deploy(
    logicInstance.address,
    proxyAdmin,
    "0x"
  );
  await proxy.deployed();

  const instance = await ContractFactory.attach(proxy.address);
  return instance;
}

export async function deployedAt(
  contract: string,
  address: string
): Promise<Contract> {
  const ContractFactory = await ethers.getContractFactory(contract);
  const instance = await ContractFactory.attach(address);
  await instance.deployed();
  return instance;
}
