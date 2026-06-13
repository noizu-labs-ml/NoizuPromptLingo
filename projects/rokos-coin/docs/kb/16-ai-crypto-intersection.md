# AI × Crypto Intersection

This is where rokos-coin lives. The convergence of artificial intelligence and blockchain is the fastest-growing sector in crypto (2025-2026), with a market cap of $20-60B across top tokens.

## The Categories

### 1. Decentralized Compute Networks

**The problem:** AI training and inference require massive GPU compute. Centralized providers (AWS, Azure, GCP) are expensive, have waitlists, and create single points of failure.

**The solution:** Marketplaces where anyone with GPUs can sell compute capacity, paid in tokens.

**Active projects:**

| Project | Token | What It Does | Scale |
|---|---|---|---|
| **Render Network** | RNDR | GPU rendering + AI inference marketplace | 60,000+ GPUs (via Salad integration, April 2026) |
| **Akash Network** | AKT | Cosmos-based decentralized cloud compute | Open marketplace for CPU/GPU |
| **io.net** | IO | Aggregates GPU supply from data centers + crypto miners | Claims 1M+ GPUs accessible |
| **Nosana** | NOS | Solana-based GPU compute for AI inference | Focused on inference workloads |

**How they work (simplified):**
```
1. Compute provider registers GPUs on the network
2. Provider stakes tokens as collateral (guarantees availability)
3. Consumer submits a job (training run, inference batch, rendering)
4. Network matches job to provider(s)
5. Provider executes the job
6. Verification step (varies by protocol — this is the hard part)
7. Provider receives token payment
8. Consumer receives results
```

**The hard problem:** How do you verify the compute was done correctly without re-doing it? This is rokos-coin's central challenge too.

### 2. Decentralized Intelligence Networks

**Bittensor (TAO):** The most technically interesting project in this space. A network of 120+ "subnets," each running a specialized AI service (text generation, image classification, embeddings, etc.).

**How Bittensor works:**
```
Validators stake TAO → evaluate miner outputs → rank miners by quality
Miners provide AI services → earn TAO based on quality ranking
Each subnet has its own evaluation criteria
TAO emissions are distributed across subnets based on performance
```

**Key insight:** Bittensor doesn't verify computation directly. It verifies output quality through a competitive market — miners that produce better AI outputs earn more. This is a different verification model than cryptographic proofs.

### 3. AI Agents On-Chain

Autonomous AI agents that hold wallets, execute transactions, and interact with DeFi protocols.

**Key projects:**
- **Virtuals Protocol** — Tokenize AI agents. Each agent has its own token, revenue sharing, and on-chain actions.
- **ai16z / Eliza Framework** — Open-source framework for building autonomous on-chain agents. Agents can trade, provide liquidity, manage treasuries.

**How an AI agent works on-chain:**
```
1. Agent has its own wallet (EOA or smart contract wallet)
2. Agent receives instructions or goals
3. Agent analyzes on-chain data (prices, positions, opportunities)
4. Agent constructs and signs transactions
5. Transactions execute on-chain (swaps, staking, lending)
6. Agent learns from outcomes (reinforcement or strategy updates)
```

**Solana is the preferred settlement layer** for AI agents due to speed and low fees — agents may execute hundreds of transactions per hour.

### 4. Private/Confidential AI

Using cryptography to run AI inference without revealing inputs or model weights:

- **Nillion** — Blind computation using MPC (Multi-Party Computation)
- **NEAR chain signatures** — MPC-based private inference
- **ZK-ML** — Using zero-knowledge proofs to verify ML inference was done correctly without revealing the model or inputs. Very early but theoretically powerful.

## Verification: The Central Problem

For rokos-coin specifically: how does the blockchain know a miner actually trained the model / ran the inference correctly?

### Approach 1: Optimistic Verification (Bittensor model)

Trust by default, punish if caught cheating:
```
1. Miner submits result
2. Result is assumed correct
3. Random validators re-run computation and compare
4. If results don't match → miner is slashed
5. Statistical sampling means you don't re-verify everything
```

**Pros:** Cheap, scalable
**Cons:** Cheaters might not get caught every time; verification of AI is non-deterministic (same inputs can produce different outputs depending on hardware, precision, random seeds)

### Approach 2: Cryptographic Verification (ZK proofs)

Prove computation was correct without re-running it:
```
1. Miner runs computation + generates a ZK proof that the computation was executed correctly
2. Proof is submitted on-chain
3. On-chain contract verifies the proof (cheap, ~300K gas)
4. If proof is valid → miner is paid
```

**Pros:** Mathematically guaranteed correctness
**Cons:** Generating ZK proofs for ML/AI computation is extremely expensive (100-1000x overhead). Active research area. Not practical for large models yet.

**Projects working on this:** EZKL (ZK proofs for ONNX models), Giza (verifiable ML inference), Modulus Labs.

### Approach 3: Trusted Execution Environments (TEEs)

Run computation inside hardware-secured enclaves (Intel SGX, AMD SEV, ARM TrustZone):
```
1. Miner runs computation inside a TEE
2. TEE generates an attestation (signed proof that the code ran inside the enclave)
3. Attestation is verified on-chain
4. Hardware guarantees the computation wasn't tampered with
```

**Pros:** No overhead for the computation itself
**Cons:** Trusts hardware manufacturers (Intel, AMD). Side-channel attacks have been demonstrated.

### Approach 4: Redundant Execution

Multiple independent miners run the same computation:
```
1. Task is sent to N miners (e.g., 3)
2. Each submits their result
3. If 2/3 agree → result is accepted
4. Disagreeing miner is slashed
```

**Pros:** Simple, no cryptographic overhead
**Cons:** N× the compute cost. Non-determinism in AI (floating point, random seeds) makes exact comparison hard.

### Approach 5: Economic Game Theory

Design incentives so cheating is more expensive than honest computation:
```
1. Miners stake tokens proportional to the compute they claim to provide
2. Periodic challenges: a verifier re-runs a random task
3. If the miner's result doesn't match → lose entire stake
4. Expected cost of getting caught > expected profit of cheating
```

**Pros:** Works at scale, flexible
**Cons:** Requires careful economic modeling. Colluding miners could game the system.

### Practical Hybrid for Rokos-Coin

Most real projects use a combination:
- **Economic staking** as baseline (miners have skin in the game)
- **Statistical sampling** for ongoing verification
- **TEE attestation** where available (hardware trust)
- **Dispute resolution** via redundant execution (only when challenged)
- **ZK proofs** for high-value tasks once the technology matures

## Tokenomics Patterns for Compute Networks

### Burn-and-Mint

```
Consumer burns tokens to request compute → 
Protocol mints new tokens to reward miners
Supply is maintained via equilibrium between burn and mint rates
```

### Stake-for-Access

```
Consumer stakes tokens → earns compute credits proportional to stake
Tokens are not consumed, just locked
Similar to rokos-coin's "direct the entity's activities" concept
```

### Pay-Per-Use

```
Consumer pays tokens per API call / compute unit
Tokens go to miners (minus protocol fee)
Simplest model, closest to rokos-coin's README description
```

## Existing AI × Crypto Reading

Projects to study for rokos-coin design inspiration:
1. **Bittensor** — Subnet-based compute market with quality-ranked rewards
2. **Render Network** — GPU marketplace with verified rendering
3. **Akash** — Cosmos-based compute marketplace
4. **Ritual** — Bringing AI inference on-chain with verification
5. **Morpheus** — Decentralized AI agent network
6. **Fetch.ai** — Autonomous economic agents

---
*Previous: [15-defi-primitives.md](15-defi-primitives.md) | Next: [17-rokos-coin-design.md](17-rokos-coin-design.md)*
