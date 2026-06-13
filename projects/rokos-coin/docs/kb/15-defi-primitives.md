# DeFi Primitives

How the building blocks of decentralized finance work at the contract level. Understanding these is essential even if rokos-coin isn't a DeFi protocol — your token will exist in this ecosystem.

## Automated Market Makers (AMMs)

Traditional exchanges use order books (buyers and sellers posting prices). AMMs replace this with math.

### Constant Product AMM (Uniswap v2 model)

The simplest AMM: a pool holds two tokens, and their product must stay constant.

```
x * y = k

Where:
  x = amount of Token A in the pool
  y = amount of Token B in the pool
  k = constant (set when liquidity is first added)
```

**Example:**
```
Pool: 100 ETH × 200,000 USDC = 20,000,000 (k)

Alice wants to buy ETH with 1,000 USDC:
  New USDC in pool: 201,000
  New ETH in pool: 20,000,000 / 201,000 = 99.50 ETH
  Alice gets: 100 - 99.50 = 0.498 ETH
  
  Effective price: 1,000 / 0.498 = ~$2,008 per ETH
  (slightly worse than the $2,000 "spot price" — this is slippage)
```

**Slippage** increases with trade size relative to pool size. Big trade in a small pool = bad price.

### Concentrated Liquidity (Uniswap v3 model)

Liquidity providers can concentrate their capital in a specific price range instead of across all prices. More capital-efficient but requires active management.

```
Instead of:  LP provides liquidity from $0 to $∞
Now:         LP provides liquidity from $1,800 to $2,200
             → Much more capital concentrated where trades actually happen
             → Better prices for traders, more fees for LPs (within range)
             → But if price moves out of range, LP earns nothing
```

### Providing Liquidity

Anyone can add tokens to a pool and earn trading fees:

```solidity
// Simplified — add liquidity to a Uniswap-style pool
router.addLiquidity(
    tokenA,           // first token address
    tokenB,           // second token address
    amountA,          // amount of token A
    amountB,          // amount of token B (must match current price ratio)
    amountAMin,       // slippage protection
    amountBMin,       // slippage protection
    msg.sender,       // LP token recipient
    block.timestamp   // deadline
);
```

You receive **LP tokens** representing your share of the pool. Burn them to withdraw your proportional share of the pool + earned fees.

### Impermanent Loss

The hidden cost of providing liquidity. If the price ratio of the two tokens changes after you deposit, you'd have been better off just holding them.

```
You deposit: 1 ETH ($2,000) + 2,000 USDC = $4,000 total
ETH doubles to $4,000

If you held: 1 ETH ($4,000) + 2,000 USDC = $6,000
In the pool: ~0.707 ETH ($2,828) + 2,828 USDC = $5,656

Impermanent loss: $6,000 - $5,656 = $344 (5.7%)
```

It's "impermanent" because if the price returns to the original ratio, the loss disappears. But in practice, it's often permanent.

## Lending Protocols (Aave/Compound model)

Overcollateralized lending: deposit collateral, borrow less than its value.

```
1. Alice deposits 10 ETH ($20,000) as collateral
2. Protocol allows 80% LTV (Loan-to-Value)
3. Alice can borrow up to $16,000 worth of USDC
4. If ETH price drops and collateral value falls below the liquidation threshold...
5. Liquidators repay part of Alice's debt and seize her collateral at a discount
```

### How Liquidation Works at the Contract Level

```solidity
// Simplified liquidation
function liquidate(address borrower, address collateral, uint256 repayAmount) external {
    // 1. Check borrower is undercollateralized
    require(getHealthFactor(borrower) < 1e18, "Not liquidatable");
    
    // 2. Liquidator repays part of the debt
    debtToken.transferFrom(msg.sender, address(this), repayAmount);
    
    // 3. Liquidator receives collateral at a discount (e.g., 5% bonus)
    uint256 collateralAmount = (repayAmount * 105) / 100;  // 5% liquidation bonus
    collateralToken.transfer(msg.sender, collateralAmount);
}
```

Liquidation bots monitor all positions continuously and race to liquidate undercollateralized positions for profit.

## Staking

### Native Staking (PoS chains)
Lock tokens to help secure the network. Earn rewards (typically 3-8% APY). Can't access tokens during staking period.

### Liquid Staking
Stake tokens but receive a liquid derivative:
- Deposit ETH → receive stETH (Lido) or rETH (Rocket Pool)
- stETH can be used in DeFi (collateral, LP, etc.) while earning staking rewards
- The liquid staking token accrues value over time as rewards accumulate

### Protocol Staking
Lock tokens in a specific protocol for governance rights, fee sharing, or boosted rewards. Different from network staking — you're committing to a protocol, not the chain.

## Oracles (Detailed)

Oracles feed external data into smart contracts. They're the bridge between the blockchain world and the real world.

### Chainlink Price Feeds

```solidity
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConsumer {
    AggregatorV3Interface internal priceFeed;
    
    constructor() {
        // ETH/USD on Ethereum mainnet
        priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    }
    
    function getLatestPrice() public view returns (int256, uint256) {
        (
            uint80 roundId,
            int256 price,      // 8 decimals (e.g., 200000000000 = $2,000.00)
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        
        require(price > 0, "Invalid price");
        require(block.timestamp - updatedAt < 3600, "Stale price");
        
        return (price, updatedAt);
    }
}
```

### Push vs. Pull Oracles

- **Push (Chainlink):** Oracle nodes push price updates on-chain at regular intervals or when prices move significantly. Always available but costs gas to maintain.
- **Pull (Pyth):** Price data is available off-chain. Consumers fetch and submit the latest price in the same transaction as their operation. Cheaper but requires more frontend work.

## Governance

On-chain voting for protocol parameter changes, upgrades, and treasury allocation.

**Standard pattern (OpenZeppelin Governor):**
```
1. Create proposal (requires minimum token holding)
2. Voting delay (e.g., 1 day — prevents flash loan attacks)
3. Voting period (e.g., 7 days)
4. Proposal passes if quorum met + majority yes
5. Timelock delay (e.g., 2 days — gives users time to exit if they disagree)
6. Execution
```

**Governance pitfalls:**
- Low voter participation (typical: 5-15% of token holders)
- Whale dominance (top 10 addresses often control majority)
- Voter apathy leads to dangerous proposals passing
- Flash loan voting attacks (mitigated by snapshot-based voting)

## Relevance to Rokos-Coin

Even though rokos-coin is a compute token, not a DeFi protocol, these primitives matter:

1. **AMM pool** — People will want to trade ROKO tokens. You'll need a Uniswap pool (or equivalent) for price discovery and liquidity.
2. **Staking** — Compute providers could stake ROKO as collateral/commitment, earning rewards for reliable service.
3. **Oracle** — Verifying computation results may need an oracle-like pattern (reporting off-chain compute results on-chain).
4. **Governance** — Protocol parameter changes (reward rates, compute pricing) could be governed by token holders.
5. **Liquidation-like mechanics** — If a compute provider takes payment but doesn't deliver, their staked collateral could be slashed (similar to lending liquidation).

---
*Previous: [14-alternative-chains.md](14-alternative-chains.md) | Next: [16-ai-crypto-intersection.md](16-ai-crypto-intersection.md)*
