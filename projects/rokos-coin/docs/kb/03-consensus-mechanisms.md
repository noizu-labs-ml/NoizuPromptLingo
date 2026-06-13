# Consensus Mechanisms

How a network of strangers agrees on what's true without a central authority.

## The Problem

If 10,000 computers each maintain a copy of the ledger, how do they all agree on the same state? What if some are lying, offline, or slow? This is the **Byzantine Generals Problem** — and consensus mechanisms are the solution.

## Proof of Work (PoW)

**Used by:** Bitcoin, Litecoin, Monero

Miners compete to solve a computational puzzle: find a number (nonce) such that `hash(block_header + nonce)` starts with N zeroes. The puzzle is hard to solve but trivial to verify.

```
Attempt 1: hash("block...847291") = 0x8a3f...  ✗ (doesn't start with enough zeroes)
Attempt 2: hash("block...847292") = 0x0000...  ✓ (winner!)
```

- **Security model:** Attacking the chain requires >50% of all mining power (hash rate)
- **Energy cost:** By design — the electricity cost is the security budget
- **Block time:** Bitcoin ~10 min; Ethereum was ~15 sec when it used PoW
- **Finality:** Probabilistic — each new block on top makes reversal exponentially harder. Convention: 6 confirmations ≈ final for Bitcoin

**Trade-off:** Extremely secure and decentralized, but energy-intensive and slow.

## Proof of Stake (PoS)

**Used by:** Ethereum (since Sept 2022 "The Merge"), Cardano, Avalanche, Solana (hybrid)

Instead of burning electricity, validators lock up ("stake") tokens as collateral. The protocol selects a validator to propose each block, weighted by stake size. Dishonest validators get **slashed** — their staked tokens are partially burned.

**Ethereum's PoS specifics:**
- Minimum stake: 32 ETH per validator
- Block time: 12 seconds (one slot)
- Finality: ~12.8 minutes (2 epochs of 32 slots each)
- Slashing: lose a portion of stake for double-signing or being offline too long

**Liquid staking:** You can stake ETH via protocols like Lido (stETH) or Rocket Pool (rETH) and get a liquid token representing your staked position. This token can be used in DeFi while your ETH earns staking rewards.

**Trade-off:** Energy-efficient, reasonably decentralized, but creates "rich get richer" dynamics — those with more stake earn more rewards.

## Delegated Proof of Stake (DPoS)

**Used by:** TRON, EOS, some Cosmos chains

Token holders vote for a small fixed set of delegates (~21 on EOS, ~27 on TRON) who take turns producing blocks. Regular holders don't validate directly — they elect representatives.

**Trade-off:** Very fast (high throughput), but significantly more centralized. A cartel of delegates can collude.

## Proof of Authority (PoA)

**Used by:** Enterprise chains, BNB Chain's validator set, most testnets

A pre-approved whitelist of validators signs blocks. No mining, no staking. Validators are known entities who put their reputation on the line.

**Trade-off:** Fast and cheap, but fully centralized. Not really "blockchain" in the trustless sense — more like a distributed database with audit trails.

## BFT Variants (Tendermint / HotStuff / PBFT)

**Used by:** Cosmos ecosystem (Tendermint/CometBFT), Aptos/Sui (HotStuff derivative), Algorand

Committee-based protocols where validators vote in rounds. A block is final when 2/3+ of validators sign off.

**Tendermint (CometBFT):**
- Used by every Cosmos chain
- Instant finality — no confirmations needed, no forks possible
- Tolerates up to 1/3 Byzantine (malicious) validators
- Block time: 1-7 seconds depending on the chain
- Trade-off: validator set is typically small (50-175); adding more slows consensus

**HotStuff (used by Aptos, formerly Libra/Diem):**
- Linear message complexity (more scalable than classic PBFT)
- Pipeline multiple proposals for higher throughput

## Comparison Table

| Mechanism | Finality | TPS | Energy | Decentralization | Security Model |
|---|---|---|---|---|---|
| PoW | Probabilistic (~60 min) | 7 (BTC) | Very high | Very high | 51% hash rate |
| PoS | Deterministic (~13 min ETH) | 15-30 (ETH L1) | Low | High | 51% stake |
| DPoS | Near-instant | 1000+ | Very low | Low-Medium | Delegate collusion |
| PoA | Instant | 1000+ | Negligible | Very low | Validator reputation |
| BFT | Instant | 100-10,000 | Low | Medium | 1/3 Byzantine fault |

## Solana's Hybrid: PoS + Proof of History (PoH)

Solana uses a unique addition: **Proof of History** — a verifiable delay function that creates a cryptographic timestamp ordering transactions before consensus. This lets validators agree on transaction order without back-and-forth communication, enabling ~400ms block times and high throughput.

It's not a consensus mechanism itself — it's a clock that makes PoS consensus faster.

## Which Consensus for Rokos-Coin?

The rokos-coin design has specific constraints:
- **High-frequency API calls** → needs fast finality and low fees (rules out PoW, expensive PoS L1)
- **Compute marketplace** → needs programmable token economics (rules out Bitcoin-style)
- **Decentralized** → can't just be a centralized API with a database

Likely candidates:
1. **Ethereum L2** (Arbitrum/Base) — inherit Ethereum security, low fees, instant UX
2. **Cosmos app-chain** — custom chain with Tendermint consensus, IBC interoperability
3. **Solana** — native speed for high-frequency operations

More analysis in [17-rokos-coin-design.md](17-rokos-coin-design.md).

---
*Previous: [02-cryptographic-primitives.md](02-cryptographic-primitives.md) | Next: [04-smart-contracts-101.md](04-smart-contracts-101.md)*
