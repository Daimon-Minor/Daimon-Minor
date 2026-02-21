const { ethers, network, run } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  const chainId    = (await ethers.provider.getNetwork()).chainId;

  console.log("\n╔══════════════════════════════════════════════╗");
  console.log("║     DMON — Daimon Minor Token Deploy         ║");
  console.log("║     by Daimon Labs  |  Base Network          ║");
  console.log("╚══════════════════════════════════════════════╝\n");

  console.log(`🔗 Network  : ${network.name} (Chain ID: ${chainId})`);
  console.log(`🚀 Deployer : ${deployer.address}`);
  console.log(`💰 Balance  : ${ethers.formatEther(
    await ethers.provider.getBalance(deployer.address)
  )} ETH\n`);

  // ── Config ───────────────────────────────────────────────────────
  const TREASURY       = process.env.TREASURY_ADDRESS  || deployer.address;
  const DAIMON_PARENT  = process.env.DAIMON_ADDRESS    || ethers.ZeroAddress;

  console.log("📋 Deploy Config:");
  console.log(`   Treasury     : ${TREASURY}`);
  console.log(`   Daimon Parent: ${DAIMON_PARENT}\n`);

  // ── Deploy ───────────────────────────────────────────────────────
  console.log("⏳ Deploying DMON...");
  const DMON   = await ethers.getContractFactory("DMON");
  const dmon   = await DMON.deploy(TREASURY, DAIMON_PARENT);
  await dmon.waitForDeployment();
  const address = await dmon.getAddress();

  console.log(`\n✅ DMON deployed!\n`);
  console.log(`   Address  : ${address}`);

  if (network.name === "base") {
    console.log(`   Explorer : https://basescan.org/token/${address}`);
  } else if (network.name === "base-sepolia") {
    console.log(`   Explorer : https://sepolia.basescan.org/token/${address}`);
  }

  // ── Token Stats ──────────────────────────────────────────────────
  const info = await dmon.tokenInfo();
  console.log("\n📊 Token Info:");
  console.log(`   Name         : ${info._name}`);
  console.log(`   Symbol       : ${info._symbol}`);
  console.log(`   Decimals     : ${info._decimals}`);
  console.log(`   Total Supply : ${ethers.formatEther(info._totalSupply)} DMON`);
  console.log(`   Max Supply   : ${ethers.formatEther(info._maxSupply)} DMON`);
  console.log(`   Burn Rate    : ${info._burnBps / 100}%`);
  console.log(`   Treasury     : ${info._treasury}`);
  console.log(`   Trading Open : ${info._tradingEnabled}`);

  // ── Next Steps ───────────────────────────────────────────────────
  console.log("\n📌 Next Steps:");
  console.log("   1. Add liquidity on Aerodrome or Uniswap v3 Base");
  console.log("   2. Call enableTrading() after LP is set");
  console.log(`   3. Verify: npx hardhat verify --network ${network.name} ${address} "${TREASURY}" "${DAIMON_PARENT}"`);
  console.log("   4. Add to Basescan token tracker\n");

  // ── Auto-verify (if not local) ───────────────────────────────────
  if (network.name !== "hardhat" && network.name !== "localhost") {
    console.log("⏳ Waiting 5 blocks for Basescan indexing...");
    await new Promise(r => setTimeout(r, 30000)); // 30s

    try {
      await run("verify:verify", {
        address,
        constructorArguments: [TREASURY, DAIMON_PARENT],
      });
      console.log("✅ Contract verified on Basescan!");
    } catch (e) {
      console.log("⚠️  Verify failed (try manually):", e.message);
    }
  }

  return address;
}

main()
  .then(() => process.exit(0))
  .catch((err) => { console.error(err); process.exit(1); });
