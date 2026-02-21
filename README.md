# 🔵 DMON — Daimon Minor Token
### *by DAIMON Protocol · Deployed on Base*

> *"The lightweight spirit of the Daimon ecosystem — built on Base"*

**DMON** is the official **gas fee & micro-transaction token** of the **DAIMON** ecosystem,
deployed on **Base** (Coinbase L2) for ultra-fast and low-cost transactions (~$0.001 per tx).

---

## 🌐 Why Base?

| Feature          | Ethereum Mainnet | Base (L2)              |
|-----------------|------------------|------------------------|
| Avg Gas Fee      | ~$5–$50          | ~$0.001–$0.01 ✅       |
| TPS              | ~15              | ~2,000+ ✅             |
| Finality         | ~12 sec          | ~2 sec ✅              |
| Security         | ✅               | ✅ (backed by ETH)     |
| EVM Compatible   | ✅               | ✅                     |

Base is the **perfect chain for micro-payment & gas tokens** like DMON.

---

## 📊 Tokenomics

| Parameter        | Value                           |
|-----------------|---------------------------------|
| **Name**        | Daimon Minor                    |
| **Symbol**      | DMON                            |
| **Chain**       | Base (Chain ID: 8453)           |
| **Standard**    | ERC-20 + ERC-20Permit           |
| **Max Supply**  | 100,000,000,000 DMON (100B)     |
| **Burn/TX**     | 1.0% (100 BPS) 🔥               |
| **Treasury/TX** | 0.5% (50 BPS) 🏦                |
| **Net Received**| 98.5% ✅                        |

### Token Distribution
```
60% → Deployer   (40% ecosystem + 20% team)
40% → Treasury   (30% liquidity + 10% reserve)
```

---

## 💸 How DMON Works

```
User sends 1000 DMON
         ↓
├── 10 DMON   → 🔥 BURNED (deflationary, supply decreases forever)
├──  5 DMON   → 🏦 Treasury (funds DAIMON ecosystem)
└── 985 DMON  → ✅ Received by recipient
```

**Use Cases:**
- ⛽ Gas fee within the DAIMON ecosystem
- 💸 Micro-payments & creator tipping
- 🎮 In-game purchases in DAIMON GameFi
- 🔄 Swap fee on DAIMON DEX (Base)
- 🤖 Pay-per-API-call in Web3 apps
- 🔗 Cross-chain bridging via Daimon Bridge

---

## 🚀 CLI — Setup & Deploy

### Prerequisites
```bash
node --version    # v18+ required
npm --version     # v8+ required
git --version
gh --version      # GitHub CLI — https://cli.github.com
```

### 1. Clone & Install
```bash
git clone https://github.com/YOUR_USERNAME/dmon-base.git
cd dmon-base
npm install
```

### 2. Setup Environment
```bash
cp .env.example .env
# Edit .env and fill in: PRIVATE_KEY, BASE_SEPOLIA_RPC, TREASURY_ADDRESS
```

### 3. Compile
```bash
npm run compile
# Output: Compiled 1 Solidity file successfully ✓
```

### 4. Test
```bash
npm test

# With gas report:
npm run test:gas
```

### 5. Deploy Testnet (Base Sepolia)
```bash
# Get free testnet ETH: https://www.coinbase.com/faucets/base-ethereum-goerli-faucet
npm run deploy:testnet
```
Example output:
```
╔══════════════════════════════════════════════════╗
║  DMON deployed successfully!
║  Contract : 0xAbCd...1234
║  Explorer : https://sepolia.basescan.org/address/0xAbCd...1234
╚══════════════════════════════════════════════════╝
```

### 6. Verify on Basescan
```bash
npm run verify:testnet
```

### 7. Deploy Mainnet (Base)
```bash
npm run deploy:mainnet
npm run verify:mainnet
```

### 8. Enable Trading (after adding liquidity)
```bash
# 1. Add DMON/WETH or DMON/USDC liquidity on aerodrome.finance
# 2. Then run:
DMON_ADDRESS=0x... npx hardhat run scripts/enableTrading.js --network base

# Output: ✅ Trading enabled! DMON is now live on Base 🔥
```

---

## 🐙 Push to GitHub & Enable CI/CD

### Create Repo & Push

**Windows (PowerShell):**
```powershell
# Install GitHub CLI first
winget install --id GitHub.cli

# Restart PowerShell, then login
gh auth login

# Create repo and push
git init
git add .
git commit -m "feat: DMON token on Base by DAIMON"
git branch -M main
gh repo create dmon-base --public --push --source=.
```

**macOS / Linux:**
```bash
gh auth login
gh repo create dmon-base --public --push --source=.
```

### Set GitHub Secrets (for CI/CD auto-deploy)
```bash
gh secret set PRIVATE_KEY        --body "your_private_key_without_0x"
gh secret set BASE_SEPOLIA_RPC   --body "https://sepolia.base.org"
gh secret set BASE_MAINNET_RPC   --body "https://mainnet.base.org"
gh secret set TREASURY_ADDRESS   --body "0xYourTreasuryWallet"
gh secret set DAIMON_ADDRESS     --body "0xDaimonParentToken"
gh secret set BASESCAN_API_KEY   --body "your_basescan_api_key"
```

### Setup GitHub Environments (for mainnet approval gate)
```
GitHub repo → Settings → Environments
→ Create: base-sepolia  (no approval needed)
→ Create: base-mainnet  (add Required Reviewers = you)
```

### CI/CD Flow
```
PR / push to develop  →  Compile → Test → Security Scan → Deploy Base Sepolia
push to main          →  Compile → Test → Security Scan → Deploy Base Mainnet
                                                           (manual approval required)
```

---

## 📁 Project Structure

```
dmon-base/
├── contracts/
│   └── DMON.sol                    ← ERC-20 + Permit + Burn + microPay
├── scripts/
│   ├── deploy.js                   ← Deploy to Base
│   ├── enableTrading.js            ← Enable after liquidity is added
│   └── verify.js                   ← Verify on Basescan
├── test/
│   └── DMON.test.js                ← Full unit tests
├── .github/
│   └── workflows/
│       └── deploy.yml              ← CI/CD pipeline for Base
├── deployments/                    ← Auto-generated deployment info
├── hardhat.config.js               ← Base network configuration
├── package.json
├── .env.example
└── README.md
```

---

## 🌐 Base Network Resources

| Resource         | URL                                                                    |
|-----------------|------------------------------------------------------------------------|
| Base Explorer   | https://basescan.org                                                   |
| Testnet Faucet  | https://www.coinbase.com/faucets/base-ethereum-goerli-faucet           |
| Base Bridge     | https://bridge.base.org                                                |
| Base RPC (free) | https://mainnet.base.org                                               |
| Base Docs       | https://docs.base.org                                                  |
| Aerodrome DEX   | https://aerodrome.finance                                              |
| Basescan API    | https://basescan.org/register                                          |

---

## 🏗️ DAIMON Ecosystem

```
DAIMON  ← Parent Token (Governance · Base)
├── DMON    → Gas & Micro-transaction  ← YOU ARE HERE 📍
├── DSOUL   → NFT & Creator Economy
├── DFIRE   → Staking & Yield
├── DECHO   → Cross-chain Bridge
└── DVEIL   → Synthetic Assets
```

---

## 🔒 Security

- Smart contract built with OpenZeppelin v5
- Anti-bot protection (trading disabled until owner enables)
- Max burn cap: 5% (cannot be set higher)
- Re-entrancy guard on `microPay()`
- Slither security scan in CI/CD pipeline

---

*🔵 Built on Base · ❤️ by DAIMON Protocol*
