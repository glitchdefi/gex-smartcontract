const fs = require("fs");

export function writeOutput(
  network: "local" | "testnet" | "mainnet",
  output: object
) {
  fs.writeFileSync(
    `${__dirname}/../output/${network}.json`,
    JSON.stringify(output, null, 2)
  );
}
