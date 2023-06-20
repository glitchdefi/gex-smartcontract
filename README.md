# Glitch Decentralized Exchange - GEX
This repo includes core and peripheral contracts of the GEX

## Requirements
+ node >= v14.
## Install Dependencies
```
npm i
```
## Compile Contracts
```
npm run compile
```

## Deploy Contracts
To deploy the contracts, follow the steps below:

1. Set up the .env file in the following format:
```
RPC_TESTNET=http://fullnodes-testnet-1.glitch.finance:9933
RPC_MAINNET=http://fullnodes-mainnet-1.glitch.finance:9933

PRIVATE_KEY=0x1f354d8b016d39...6a91ec894f4d14ff9075e45

FEE_TO="0x3DBC4548b4...650f3790F54481C1"
FEE_TO_SETTER="0x3DBC4548b4...650f3790F54481C1"
```

+ PRIVATE_KEY: The private key of the owner used for deploying the contracts.
+ FEE_TO_SETTER: The address used for configuring the fee recipient address for the protocol.
+ FEE_TO: The address used for receiving the protocol fee. 

2. Deploy the Factory contract first by running the command: 
+ On testnet,
```
npm run deploy_factory:testnet
```
+ On mainnet,
```
npm run deploy_factory:mainnet
```

+ Output:
```
Deploying on chain ID: 43113
Deployer 0x3DBC4548b4194Ae95Ef212BB650f3790F54481C1 has balance: 3.013260121381803298

Deploying Factory contract with params:
+ feeToSetter: 0x3DBC4548b4194Ae95Ef212BB650f3790F54481C1
Factory deployed at: 0x85e36756E03f6bE7d0549F0484d43E2c92dE8c69

Setting feeTo...
+ feeTo: 0x3DBC4548b4194Ae95Ef212BB650f3790F54481C1
Set feeTo at: 0xa0c36761bd4694ffefde5e2b9c8f35fa18690e402a5c95c4c570c241c98108f3

NOTE: You must replace the default INIT_CODE_PAIR_HASH and re-compile before deploying the GEXRouter contract.
Copy 9b7a234513ebe38e9cf4936e1ce93720699a9e264ca502e2299f6c9f0a028d45 to line 38 in contracts/libraries/GEXLibrary.sol file
Then, run: npx run compile
DONE
```
3. Copy the INIT_CODE_PAIR_HASH (from the above output) and paste it on line 38 in the contracts/libraries/GEXLibrary.sol file.  
+ Once done, re-compile the contracts by running the command: 
```
npm run compile
```
4. Finally, deploy the Router contract and other contracts by running the following command:
+ On testnet,
```
npm run deploy_router:testnet
```
+ On mainnet,
```
npm run deploy_router:mainnet
```
+ Output:
```
Deploying on chain ID: 43113
Deployer 0x3DBC4548b4194Ae95Ef212BB650f3790F54481C1 has balance: 2.934922371381803298

wGLCH deploying...
wGLCH deployed at: 0xA1e499e7386308d8C12Cc406b9C62866Cc8998Be

GEXRouter01 deploying...
GEXRouter01 deployed at: 0xe2b46b6e483d1Dd422E108fE7eE5D80D5d61EA34

Multicall deploying...
Multicall deployed at: 0xA3e16EDE9d0D54400D58e3cF6266D67059F55Cb5
DONE
```
5. All deployment outcomes can be found in the `scripts/output/{{network}}.json` file.
+  For example, `scripts/output/mainnet.json`
```
{
  "GEXFactory": {
    "address": "0x85e36756E03f6bE7d0549F0484d43E2c92dE8c69",
    "vars": {
      "INIT_CODE_PAIR_HASH": "0x9b7a234513ebe38e9cf4936e1ce93720699a9e264ca502e2299f6c9f0a028d45",
      "feeTo": "0x3DBC4548b4194Ae95Ef212BB650f3790F54481C1",
      "feeToSetter": "0x3DBC4548b4194Ae95Ef212BB650f3790F54481C1"
    }
  },
  "GEXRouter01": {
    "address": "0xe2b46b6e483d1Dd422E108fE7eE5D80D5d61EA34",
    "vars": {
      "factory": "0x85e36756E03f6bE7d0549F0484d43E2c92dE8c69",
      "WGLCH": "0xA1e499e7386308d8C12Cc406b9C62866Cc8998Be"
    }
  },
  "Multicall": {
    "address": "0xA3e16EDE9d0D54400D58e3cF6266D67059F55Cb5"
  }
}
```
