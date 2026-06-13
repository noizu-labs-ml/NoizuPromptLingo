# Layer 2 Scaling

## The Scaling Problem

Ethereum L1 processes ~15-30 transactions per second. That's fine for high-value DeFi but useless for applications needing thousands of transactions per second at sub-cent fees (like, say, an API-per-call payment system).

Layer 2 (L2) solutions process transactions off-chain but inherit Ethereum's security by posting proofs or data back to L1.

## Types of L2s

### Optimistic Rollups

**How they work:**
1. Transactions are executed off-chain by a **sequencer**
2. Transaction data is posted to Ethereum L1 (compressed)
3. Anyone can challenge a result within a **dispute window** (typically 7 days)
4. If challenged, a **fraud proof** is computed on L1 to settle the dispute
5. If no challenge, the result is accepted as final

**The optimistic assumption:** Assume all transactions are valid unless proven otherwise. Only compute fraud proofs when someone objects.

```
Users → L2 Sequencer → Batch transactions → Post to L1
                                              ↓
                                    7-day dispute window
                                              ↓
                                    Finalized on L1
```

**Trade-off:** Cheap and fast, but 7-day withdrawal window to L1 (bridging services offer faster exits for a fee).

### ZK (Zero-Knowledge) Rollups

**How they work:**
1. Transactions are executed off-chain
2. A **validity proof** (ZK-SNARK or ZK-STARK) is computed, proving all transactions were executed correctly
3. The proof + state delta is posted to Ethereum L1
4. L1 contract verifies the proof (cheap, ~300K gas regardless of batch size)
5. Immediately final — no dispute window needed

```
Users → L2 Sequencer → Batch transactions → Generate ZK proof → Post proof to L1
                                                                    ↓
                                                            Immediately verified
```

**Trade-off:** Immediate finality, but proof generation is computationally expensive and the technology is newer/more complex.

## The L2 Landscape (May 2026)

### Optimistic Rollups

| Chain | TVL | Avg TPS | Avg Tx Fee | Stack | Notes |
|---|---|---|---|---|---|
| **Arbitrum One** | $16.6B | 62 | ~$0.09 | Custom (Nitro) | DeFi-dominant, deepest liquidity |
| **Base** | $11.2B | 89 | ~$0.05 | OP Stack | Coinbase-backed, consumer/retail default |
| **OP Mainnet** | ~$6B | 34 | ~$0.09 | OP Stack | Anchor of the Superchain ecosystem |

**Arbitrum** — The DeFi powerhouse. Most protocols deploy here first. Arbitrum Stylus adds support for Rust/C++ contracts alongside Solidity.

**Base** — Coinbase's L2. Highest throughput, lowest fees, massive retail distribution. If you're building consumer-facing, this is the default.

**OP Mainnet** — The OP Stack is the framework other L2s build on (Base, Worldcoin, etc.). "The Superchain" vision: many OP Stack chains sharing a security layer.

### ZK Rollups

| Chain | Avg TPS | Stack | Notes |
|---|---|---|---|
| **zkSync Era** | 28 | zkEVM (custom) | Enterprise adoption (Deutsche Bank), ZK-native |
| **Starknet** | 19 | STARK-based (Cairo) | Highest theoretical throughput ceiling, custom language |
| **Scroll** | 22 | zkEVM (EVM-equivalent) | Most EVM-compatible ZK rollup |
| **Linea** | 14 | zkEVM | ConsenSys-backed |
| **Polygon zkEVM** | - | zkEVM | Part of Polygon's AggLayer |

**zkSync** — Most mature ZK rollup. Enterprise traction. Native account abstraction.

**Starknet** — Uses Cairo language (not Solidity). Highest theoretical throughput but requires learning a new language.

**Scroll** — Most EVM-compatible ZK rollup. Deploy existing Solidity contracts with minimal changes.

## Key L2 Concepts

### Sequencers

Every L2 currently has a **centralized sequencer** — a single entity that orders transactions and produces blocks. This is the known centralization point.

**Implications:**
- The sequencer can censor transactions (temporarily)
- The sequencer extracts MEV
- If the sequencer goes down, the L2 halts (but funds are safe on L1)

**Decentralized sequencing** is the active unsolved problem across all L2s. Various approaches are in development (shared sequencing, based rollups, etc.) but none are production-ready as of mid-2026.

### Data Availability

L2s must post transaction data somewhere so anyone can reconstruct the state and verify correctness.

**Options:**
- **On-chain (calldata/blobs)** — Posted to Ethereum L1. Most secure, most expensive.
- **EIP-4844 (Proto-Danksharding)** — Dedicated "blob" space on Ethereum. Cheaper than calldata. Live since March 2024.
- **Off-chain (Validium/Volition)** — Posted to a separate DA layer (Celestia, EigenDA, Avail). Cheapest, but weaker security guarantee.

### Bridges

Moving assets between L1 and L2 (or between L2s):

- **Native bridge** — Built into the rollup. Secure (inherits rollup security) but slow for optimistic rollups (7-day withdrawal).
- **Third-party bridges** — Faster withdrawals via liquidity networks (Across, Stargate, Hop). Trade speed for trust assumptions.
- **Cross-L2 messaging** — Sending messages between different L2s. Standards emerging but fragmented.

**Bridge security:** Bridges have been the #1 target for large exploits ($2B+ in bridge hacks historically). The native bridge is always the safest option.

## Deploying to L2s

For most Solidity contracts, deploying to an L2 is nearly identical to deploying to Ethereum:

```bash
# Foundry — just change the RPC URL
forge script script/Deploy.s.sol --rpc-url https://arb1.arbitrum.io/rpc --broadcast

# Hardhat — add network to config
npx hardhat ignition deploy ignition/modules/Token.ts --network arbitrum
```

**Differences to watch for:**
- Gas pricing models differ per L2 (L2 execution gas + L1 data posting gas)
- Some opcodes behave differently (e.g., `PUSH0` support varies)
- Block times differ (Arbitrum: 250ms, Base: 2s, Ethereum: 12s)
- `block.number` and `block.timestamp` semantics may differ

## Which L2 for Rokos-Coin?

Given rokos-coin's requirements (high-frequency API calls, low fees, programmable payments):

| Option | Pros | Cons |
|---|---|---|
| **Base** | Lowest fees, highest throughput, Coinbase distribution, massive retail reach | Centralized sequencer, Coinbase dependency |
| **Arbitrum** | Deepest DeFi liquidity, Stylus (Rust contracts), most mature | Slightly higher fees than Base |
| **zkSync** | Native account abstraction, ZK proofs, enterprise adoption | Smaller ecosystem, newer |
| **Starknet** | Highest theoretical throughput, ZK-native | Requires Cairo (not Solidity), small ecosystem |
| **Custom L2/L3** | Full control, custom gas token possible | Massive engineering effort |

**My honest take:** Start on Base or Arbitrum. They have the users, the tooling, and the liquidity. Move to a custom L3 or app-chain later if you need it. Premature chain-building is the #1 time sink in crypto projects.

---
*Previous: [12-audit-patterns.md](12-audit-patterns.md) | Next: [14-alternative-chains.md](14-alternative-chains.md)*
