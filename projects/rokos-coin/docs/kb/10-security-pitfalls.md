# Security Pitfalls & Common Exploits

Smart contract security is the hardest part of blockchain development. Bugs are permanent, public, and directly drain money. This document covers the attack categories that have caused the most damage.

## Tier 1: Classic Contract Vulnerabilities

### Reentrancy ($420M+ in losses)

The attacker's contract calls back into your contract before your state update completes.

```
Victim.withdraw() 
    → sends ETH to Attacker
    → Attacker.receive() calls Victim.withdraw() again
    → Victim still thinks Attacker has funds (balance not yet updated)
    → Loop until drained
```

**The DAO Hack (2016):** $60M drained. Led to the Ethereum/Ethereum Classic hard fork.

**Prevention:**
1. **Checks-Effects-Interactions pattern** — Update state before making external calls
2. **ReentrancyGuard** — OpenZeppelin's `nonReentrant` modifier
3. **Pull over push** — Don't send ETH in the same function that calculates amounts. Let users withdraw separately.

**Cross-function reentrancy:** Attacker re-enters a different function that reads the same stale state. Harder to spot. ReentrancyGuard covers this.

**Read-only reentrancy:** Attacker re-enters a view function on a different contract that reads stale state from your contract. Increasingly common in DeFi composability.

### Access Control Failures

Missing or incorrect permission checks. Deployer forgets to restrict admin functions.

```solidity
// VULNERABLE — anyone can mint tokens
function mint(address to, uint256 amount) external {
    _mint(to, amount);
}

// FIXED
function mint(address to, uint256 amount) external onlyOwner {
    _mint(to, amount);
}
```

**Common mistakes:**
- Forgetting `onlyOwner` / `onlyRole` on sensitive functions
- Using `tx.origin` instead of `msg.sender` (phishing vulnerability)
- Not revoking deployer privileges after initialization
- Unprotected `initialize()` functions on proxy implementations

### Unchecked Return Values

Some token contracts don't revert on failure — they return `false`. If you don't check, you think the transfer succeeded.

```solidity
// VULNERABLE — USDT's transfer() doesn't return a bool
token.transfer(recipient, amount);  // might silently fail

// SAFE — use OpenZeppelin's SafeERC20
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
using SafeERC20 for IERC20;
token.safeTransfer(recipient, amount);  // reverts on failure
```

## Tier 2: DeFi-Era Attacks

### Flash Loan Attacks ($380M+ in losses, 2024-2025)

Flash loans let you borrow any amount with zero collateral — as long as you repay in the same transaction. If you don't repay, the entire transaction reverts.

**The attack pattern:**
```
1. Borrow $100M in a flash loan
2. Use $100M to manipulate a price oracle (swap on a thin-liquidity pool)
3. The manipulated price triggers your target protocol to act incorrectly
4. Extract funds from the target
5. Repay the $100M flash loan + fee
6. Profit: you keep everything extracted minus the loan fee
```

**Prevention:**
- Don't use spot prices from AMMs as oracles
- Use Chainlink or TWAP (Time-Weighted Average Price) oracles
- Add circuit breakers that pause on extreme price movements

### Oracle Manipulation

Any time your contract depends on external price data, that data is an attack surface.

**Categories:**
- **Spot price manipulation** — Manipulate a DEX pool in the same transaction
- **Stale price feeds** — Oracle hasn't updated; price is outdated
- **Centralized oracle compromise** — Single point of failure

**Prevention:**
```solidity
(, int256 price,, uint256 updatedAt,) = priceFeed.latestRoundData();
require(price > 0, "Invalid price");
require(block.timestamp - updatedAt < 3600, "Stale price");  // max 1 hour old
```

### MEV (Maximal Extractable Value)

Validators and "searchers" can see your pending transactions in the mempool and exploit them.

**Sandwich attack:**
```
1. You submit: swap 10 ETH for USDC on Uniswap
2. Attacker front-runs: buys USDC (price goes up)
3. Your swap executes at a worse price
4. Attacker back-runs: sells USDC at the higher price
5. You got less USDC; attacker pockets the difference
```

**Other MEV forms:**
- **Arbitrage** — Exploiting price differences between DEXes (generally benign)
- **Liquidation** — Racing to liquidate undercollateralized positions (can be aggressive)
- **Time-bandit attacks** — Reorging blocks to extract past MEV (theoretical, rare)

**Mitigation:**
- Use **Flashbots Protect** — Submits transactions privately (not visible in public mempool)
- Set reasonable **slippage tolerance** on swaps
- Use DEXes with built-in MEV protection (e.g., CoW Swap's batch auctions)

### Governance Attacks

Token-weighted voting can be manipulated:
- Flash loan tokens → vote → return tokens (all in one transaction)
- Accumulate tokens just before a vote snapshot

**Prevention:** Snapshot-based voting (votes counted at a past block), timelock delays on execution.

## Tier 3: Structural/Design Vulnerabilities

### Upgrade Proxy Misconfigurations

```
Proxy (storage) → Implementation v1 (logic)
                 ↓ upgrade
                → Implementation v2 (logic)
```

**Common mistakes:**
- **Uninitialized implementation** — Attacker calls `initialize()` on the implementation contract directly (not through the proxy), becoming the owner
- **Storage collision** — New implementation uses a storage slot differently than the old one, corrupting data
- **Function selector clash** — A proxy admin function has the same selector as an implementation function

**Prevention:** Use OpenZeppelin's `Initializable` and well-tested proxy patterns. Always initialize implementation contracts.

### Composability Risks

DeFi protocols build on each other. A bug in one can cascade:

```
Protocol A uses Token X as collateral
Token X's pricing comes from Protocol B's oracle
Protocol B reads from AMM Pool C
An attacker manipulates Pool C → Protocol B reports wrong price → Protocol A liquidates incorrectly
```

This is not hypothetical — it's the pattern behind dozens of exploits.

### Approval Phishing

The most common attack on end users. A malicious dApp tricks users into signing an `approve()` call for `type(uint256).max`, giving the attacker's contract unlimited access to drain tokens.

**Prevention:**
- Approve exact amounts, not unlimited
- Use ERC-2612 Permit (off-chain signatures) to limit approval windows
- Regularly audit and revoke approvals (revoke.cash)

## The Security Mindset

1. **Assume every external call is hostile** — The target contract might be malicious or compromised
2. **Assume every user input is malicious** — Validate everything
3. **Assume your code has bugs** — Get audits, run fuzzers, have bug bounties
4. **Minimize attack surface** — Fewer functions, simpler logic, less composability = fewer vulnerabilities
5. **Fail closed** — If something unexpected happens, revert. Don't try to "handle" unknown states.
6. **Defense in depth** — Multiple layers: access control + reentrancy guards + invariant checks + monitoring

---
*Previous: [09-infrastructure.md](09-infrastructure.md) | Next: [11-security-tools.md](11-security-tools.md)*
