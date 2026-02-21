// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * ██████╗ ███╗   ███╗ ██████╗ ███╗   ██╗
 * ██╔══██╗████╗ ████║██╔═══██╗████╗  ██║
 * ██║  ██║██╔████╔██║██║   ██║██╔██╗ ██║
 * ██║  ██║██║╚██╔╝██║██║   ██║██║╚██╗██║
 * ██████╔╝██║ ╚═╝ ██║╚██████╔╝██║ ╚████║
 * ╚═════╝ ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
 *
 * @title  DMON — Daimon Minor Token
 * @notice Gas fee & micro-transaction token for the Daimon Ecosystem
 * @dev    Deployed on Base (Coinbase L2) — Chain ID: 8453
 * @author Daimon Labs
 *
 * Explorer : https://basescan.org
 * Docs     : https://docs.daimon.finance
 */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DMON is ERC20, ERC20Burnable, ERC20Permit, Ownable, ReentrancyGuard {

    // ═══════════════════════════════════════════════════════════════
    //  CONSTANTS
    // ═══════════════════════════════════════════════════════════════

    uint256 public constant MAX_SUPPLY      = 100_000_000_000 * 10 ** 18; // 100 Billion DMON
    uint256 public constant BURN_BPS        = 100;   // 1.0% burn per tx
    uint256 public constant TREASURY_BPS    = 50;    // 0.5% to treasury
    uint256 public constant MAX_BURN_CAP    = 500;   // safety: max 5%
    uint256 public constant BPS_DENOM       = 10_000;
    uint256 public constant BASE_CHAIN_ID   = 8453;

    // ═══════════════════════════════════════════════════════════════
    //  STATE
    // ═══════════════════════════════════════════════════════════════

    address public treasuryWallet;
    address public daimonParent;        // DAIMON parent token address
    address public daimonBridge;        // bridge contract (Base ↔ other chains)

    bool    public burnEnabled    = true;
    bool    public tradingEnabled = false; // anti-bot: owner enables after LP added

    uint256 public burnBps        = BURN_BPS;
    uint256 public treasuryBps    = TREASURY_BPS;

    // On-chain stats
    uint256 public totalBurned;
    uint256 public totalTreasuryFee;
    uint256 public totalTransactions;

    // Fee-exempt (DEX router, bridge, treasury, owner)
    mapping(address => bool) public isFeeExempt;

    // ═══════════════════════════════════════════════════════════════
    //  EVENTS
    // ═══════════════════════════════════════════════════════════════

    event MicroPayment(address indexed from, address indexed to, uint256 amount, string memo);
    event BurnRateUpdated(uint256 oldBps, uint256 newBps);
    event TreasuryUpdated(address indexed oldAddr, address indexed newAddr);
    event FeeExemptSet(address indexed account, bool exempt);
    event TradingOpened(uint256 timestamp);
    event BridgeSet(address indexed bridge);

    // ═══════════════════════════════════════════════════════════════
    //  CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════

    constructor(
        address _treasury,
        address _daimonParent
    )
        ERC20("Daimon Minor", "DMON")
        ERC20Permit("Daimon Minor")
        Ownable(msg.sender)
    {
        require(_treasury != address(0), "DMON: zero treasury");
        treasuryWallet = _treasury;
        daimonParent   = _daimonParent;

        // Default fee-exempt
        isFeeExempt[msg.sender] = true;
        isFeeExempt[_treasury]  = true;
        isFeeExempt[address(0)] = true;

        // ── Token Distribution ────────────────────────────────────
        _mint(msg.sender, (MAX_SUPPLY * 40) / 100); // 40% Ecosystem & Public
        _mint(_treasury,  (MAX_SUPPLY * 30) / 100); // 30% Liquidity Pool
        _mint(msg.sender, (MAX_SUPPLY * 20) / 100); // 20% Team (vesting)
        _mint(_treasury,  (MAX_SUPPLY * 10) / 100); // 10% Reserve
    }

    // ═══════════════════════════════════════════════════════════════
    //  TRANSFER LOGIC  (burn + treasury on every tx)
    // ═══════════════════════════════════════════════════════════════

    function transfer(address to, uint256 amount) public override returns (bool) {
        _dmonTransfer(_msgSender(), to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _spendAllowance(from, _msgSender(), amount);
        _dmonTransfer(from, to, amount);
        return true;
    }

    function _dmonTransfer(address from, address to, uint256 amount) internal {
        require(from   != address(0), "DMON: from zero address");
        require(to     != address(0), "DMON: to zero address");
        require(amount  > 0,          "DMON: zero amount");

        // Anti-bot gate
        if (!isFeeExempt[from] && !isFeeExempt[to]) {
            require(tradingEnabled, "DMON: trading not open yet");
        }

        // Skip fee if exempt
        if (isFeeExempt[from] || isFeeExempt[to] || !burnEnabled) {
            _transfer(from, to, amount);
            totalTransactions++;
            return;
        }

        uint256 burnAmt     = (amount * burnBps)     / BPS_DENOM;
        uint256 treasuryAmt = (amount * treasuryBps) / BPS_DENOM;
        uint256 receiveAmt  = amount - burnAmt - treasuryAmt;

        if (burnAmt > 0) {
            _burn(from, burnAmt);
            totalBurned += burnAmt;
        }

        if (treasuryAmt > 0) {
            _transfer(from, treasuryWallet, treasuryAmt);
            totalTreasuryFee += treasuryAmt;
        }

        _transfer(from, to, receiveAmt);
        totalTransactions++;
    }

    // ═══════════════════════════════════════════════════════════════
    //  MICRO-PAYMENT  — core utility on Base L2
    // ═══════════════════════════════════════════════════════════════

    /**
     * @dev  Send micro-payment with on-chain memo.
     *       Base's ultra-low gas makes this practical for:
     *       ⛽ Gas subsidies within Daimon dApps
     *       💸 Creator tips ($0.001 level)
     *       🎮 In-game item purchases
     *       📡 Pay-per-API-call billing
     *       📰 Pay-per-article / paywall
     *
     * @param to     Recipient wallet
     * @param amount Amount in DMON wei
     * @param memo   On-chain note (max 64 bytes)
     */
    function microPay(
        address to,
        uint256 amount,
        string calldata memo
    ) external nonReentrant returns (bool) {
        require(bytes(memo).length <= 64, "DMON: memo max 64 chars");
        _dmonTransfer(_msgSender(), to, amount);
        emit MicroPayment(_msgSender(), to, amount, memo);
        return true;
    }

    // ═══════════════════════════════════════════════════════════════
    //  OWNER CONTROLS
    // ═══════════════════════════════════════════════════════════════

    /// @notice Call AFTER adding liquidity on Aerodrome / Uniswap v3 Base
    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "DMON: already open");
        tradingEnabled = true;
        emit TradingOpened(block.timestamp);
    }

    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), "DMON: zero address");
        emit TreasuryUpdated(treasuryWallet, _treasury);
        isFeeExempt[_treasury] = true;
        treasuryWallet = _treasury;
    }

    function setBurnRate(uint256 _burnBps) external onlyOwner {
        require(_burnBps <= MAX_BURN_CAP, "DMON: exceeds max burn cap");
        emit BurnRateUpdated(burnBps, _burnBps);
        burnBps = _burnBps;
    }

    function setTreasuryRate(uint256 _bps) external onlyOwner {
        require(_bps <= 200, "DMON: treasury fee too high");
        treasuryBps = _bps;
    }

    function setFeeExempt(address account, bool exempt) external onlyOwner {
        isFeeExempt[account] = exempt;
        emit FeeExemptSet(account, exempt);
    }

    function setBridge(address _bridge) external onlyOwner {
        require(_bridge != address(0), "DMON: zero bridge");
        daimonBridge         = _bridge;
        isFeeExempt[_bridge] = true;
        emit BridgeSet(_bridge);
    }

    function toggleBurn(bool _enabled) external onlyOwner {
        burnEnabled = _enabled;
    }

    // ═══════════════════════════════════════════════════════════════
    //  VIEW HELPERS
    // ═══════════════════════════════════════════════════════════════

    function circulatingSupply() external view returns (uint256) {
        return totalSupply();
    }

    /// @return pct Burned percentage in BPS (100 = 1%)
    function burnedPercentageBps() external view returns (uint256) {
        return (totalBurned * BPS_DENOM) / MAX_SUPPLY;
    }

    function tokenInfo() external view returns (
        string memory _name,
        string memory _symbol,
        uint8         _decimals,
        uint256       _totalSupply,
        uint256       _maxSupply,
        uint256       _totalBurned,
        uint256       _burnBps,
        address       _treasury,
        bool          _tradingEnabled,
        uint256       _txCount
    ) {
        return (
            name(), symbol(), decimals(),
            totalSupply(), MAX_SUPPLY, totalBurned,
            burnBps, treasuryWallet, tradingEnabled, totalTransactions
        );
    }
}
