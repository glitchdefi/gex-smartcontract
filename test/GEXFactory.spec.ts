import chai, { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, BigNumber } from "ethers";
import { constants } from "ethers";
import { deployedAt } from "../scripts/utils/contract";
import { solidity } from "ethereum-waffle";
import { getCreate2Address } from "./shared/utilities";
import { factoryFixture } from "./shared/fixtures";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import GEXPair from "../artifacts/contracts/swap-core/GEXPair.sol/GEXPair.json";

chai.use(solidity);

const TEST_ADDRESSES: [string, string] = [
  "0x1000000000000000000000000000000000000000",
  "0x2000000000000000000000000000000000000000",
];

describe("GEXFactory", () => {
  let ownerAddress: string;
  let factory: Contract;
  let owner: SignerWithAddress;
  let other: SignerWithAddress;

  beforeEach(async () => {
    [owner, other] = await ethers.getSigners();
    const fixture = await factoryFixture(owner);
    factory = fixture.factory;
    ownerAddress = owner.address;
  });

  it("feeTo, feeToSetter, allPairsLength", async () => {
    expect(await factory.feeTo()).to.eq(constants.AddressZero);
    expect(await factory.feeToSetter()).to.eq(ownerAddress);
    expect(await factory.allPairsLength()).to.eq(0);
  });

  async function createPair(tokens: [string, string]) {
    const bytecode = `${GEXPair.bytecode}`;
    const create2Address = getCreate2Address(factory.address, tokens, bytecode);
    await expect(factory.createPair(...tokens))
      .to.emit(factory, "PairCreated")
      .withArgs(
        TEST_ADDRESSES[0],
        TEST_ADDRESSES[1],
        create2Address,
        BigNumber.from(1)
      );

    await expect(factory.createPair(...tokens)).to.be.reverted; // GEX: PAIR_EXISTS
    await expect(factory.createPair(...tokens.slice().reverse())).to.be
      .reverted; // GEX: PAIR_EXISTS
    expect(await factory.getPair(...tokens)).to.eq(create2Address);
    expect(await factory.getPair(...tokens.slice().reverse())).to.eq(
      create2Address
    );
    expect(await factory.allPairs(0)).to.eq(create2Address);
    expect(await factory.allPairsLength()).to.eq(1);

    const pair = await deployedAt("GEXPair", create2Address);

    expect(await pair.factory()).to.eq(factory.address);
    expect(await pair.token0()).to.eq(TEST_ADDRESSES[0]);
    expect(await pair.token1()).to.eq(TEST_ADDRESSES[1]);
  }

  it("createPair", async () => {
    await createPair(TEST_ADDRESSES);
  });

  it("createPair:reverse", async () => {
    await createPair(TEST_ADDRESSES.slice().reverse() as [string, string]);
  });

  it("createPair:gas", async () => {
    const tx = await factory.createPair(...TEST_ADDRESSES);
    const receipt = await tx.wait();
    expect(receipt.gasUsed).to.eq(2516699);
  });

  it("setFeeTo", async () => {
    await expect(
      factory.connect(other).setFeeTo(other.address)
    ).to.be.revertedWith("GEX: FORBIDDEN");
    await factory.setFeeTo(owner.address);
    expect(await factory.feeTo()).to.eq(owner.address);
  });

  it("setFeeToSetter", async () => {
    await expect(
      factory.connect(other).setFeeToSetter(other.address)
    ).to.be.revertedWith("GEX: FORBIDDEN");
    await factory.setFeeToSetter(other.address);
    expect(await factory.feeToSetter()).to.eq(other.address);
    await expect(factory.setFeeToSetter(owner.address)).to.be.revertedWith(
      "GEX: FORBIDDEN"
    );
  });
});
