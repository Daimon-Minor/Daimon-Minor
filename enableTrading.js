const { ethers, network } = require("hardhat");

/**
 * enableTrading.js
 * Run AFTER you have added liquidity on Aerodrome / Uniswap v3 Base
 *
 * Usage:
 *   DMON_ADDRESS=0x... npx hardhat run scripts/enableTrading.js --network base
 */
async function main() {
  const [owner] = await ethers.getSigners();
  const dmonAddress = process.env.DMON_ADDRESS;

  if (!dmonAddress) {
    console.error("❌ Set DMON_ADDRESS env var first");
    process.exit(1);
  }

  const dmon = await ethers.getContractAt("DMON", dmonAddress);

  console.log(`\n🔓 Enabling trading on DMON`);
  console.log(`   Network : ${network.name}`);
  console.log(`   Address : ${dmonAddress}`);
  console.log(`   Owner   : ${owner.address}\n`);

  const tradingBefore = await dmon.tradingEnabled();
  if (tradingBefore) {
    console.log("✅ Trading is already enabled!");
    return;
  }

  const tx = await dmon.enableTrading();
  await tx.wait();

  console.log(`✅ Trading enabled! Tx: ${tx.hash}`);
  console.log(`   DMON is now live on Base 🔥\n`);
}

main()
  .then(() => process.exit(0))
  .catch((err) => { console.error(err); process.exit(1); });
