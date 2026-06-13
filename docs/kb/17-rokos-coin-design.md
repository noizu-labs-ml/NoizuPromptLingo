# Rokos-Coin Architecture Design Space

Mapping the conceptual design from the README to concrete blockchain architecture decisions.

## Recap: What Rokos-Coin Needs

From the README, the system requires:

1. **A token (ROKO)** representing compute rights / network direction capacity
2. **Miner rewards** — Compensation for providing computation for AI training/inference
3. **API-as-payment** — Consume coins via API calls (send token + args → receive AI response)
4. **Value accrual** — Token value increases as the AI entity's capabilities grow
5. **Compute marketplace** — Providers host specialized hardware, set pricing, earn tokens
6. **Self-sustaining entity** — The AI accrues assets via API revenue, investments, automation

## Architecture Decision: Chain Selection

### Option A: Ethereum L2 (Recommended Starting Point)

Deploy contracts on Base or Arbitrum.

```
┌─────────────────────────────────────────────┐
│ Ethereum L1 (security layer)                │
├─────────────────────────────────────────────┤
│ Base/Arbitrum L2                            │
│ ┌─────────────┐  ┌──────────────────────┐  │
│ │ ROKO Token  │  │ Compute Marketplace  │  │
│ │ (ERC-20)    │  │ - Register miners    │  │
│ │             │  │ - Submit tasks       │  │
│ │             │  │ - Verify results     │  │
│ │             │  │ - Distribute rewards │  │
│ └─────────────┘  └──────────────────────┘  │
│ ┌──────────────────────────────────────┐    │
│ │ API Gateway Contract               │    │
│ │ - Accept ROKO payment + task params │    │
│ │ - Emit ComputeRequest event        │    │
│ │ - Settle on completion             │    │
│ └──────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
         ↕ events / off-chain
┌─────────────────────────────────────────────┐
│ Off-Chain Compute Layer                     │
│ - Miners listen for ComputeRequest events   │
│ - Execute AI tasks                          │
│ - Submit results + proof                    │
│ - Indexer (The Graph) tracks state          │
└─────────────────────────────────────────────┘
```

**Pros:**
- Widest tooling (Solidity, Foundry, OpenZeppelin)
- Deepest liquidity (easy for users to buy/sell ROKO)
- Battle-tested infrastructure
- Low fees (~$0.05-$0.10 per transaction)

**Cons:**
- Still not free (high-frequency API calls add up)
- Limited customization of chain behavior
- Dependent on L2 sequencer availability

### Option B: Solana Program

```
Solana Mainnet
┌──────────────────────────┐
│ ROKO SPL Token           │  ← Token-2022 with transfer hooks
│ Compute Marketplace      │  ← Anchor program
│ API Gateway              │  ← Accept ROKO + params, emit events
└──────────────────────────┘
         ↕
Off-Chain Compute Layer (same as above)
```

**Pros:**
- Sub-second finality (~400ms)
- Near-zero fees (~$0.00025)
- Strong AI×Crypto ecosystem already exists
- Parallel transaction execution

**Cons:**
- Rust learning curve
- Solana's account model is unfamiliar coming from EVM
- Network has had stability issues historically
- Smaller DeFi ecosystem than Ethereum L2s

### Option C: Cosmos App-Chain

Build a dedicated chain with Cosmos SDK + CosmWasm.

**Pros:**
- Full sovereignty (custom gas token = ROKO itself)
- Custom consensus rules for compute verification
- IBC for cross-chain liquidity

**Cons:**
- Massive engineering effort to build and maintain a chain
- Need to recruit validators
- Smaller developer ecosystem

**Verdict:** Start with **Option A (L2)** or **Option B (Solana)**. Build the protocol, prove the model works, get users. Option C is for when you've outgrown the others.

## Architecture Decision: Compute Verification

This is the hardest technical problem. See [16-ai-crypto-intersection.md](16-ai-crypto-intersection.md) for the full landscape.

**Recommended phased approach:**

### Phase 1: Economic + Redundant (MVP)
```
- Miners stake ROKO as collateral
- Tasks are sent to 3 miners
- 2/3 agreement = accepted result
- Disagreeing miner's stake is slashed
- Simple, works today, no exotic crypto needed
```

### Phase 2: Economic + Statistical Sampling
```
- Tasks sent to 1 miner (cheap)
- Random 10% are re-verified by a second miner
- Mismatches trigger full re-verification + slashing
- Reduces redundancy cost by ~67%
```

### Phase 3: TEE Attestation (when feasible)
```
- Miners run inside TEEs
- Hardware attestation proves correct execution
- No redundancy needed for attested computation
- Reduces cost to ~0% overhead
```

### Phase 4: ZK Verification (future)
```
- Miners generate ZK proofs of computation
- On-chain verification is cheap and trustless
- The ultimate goal, but technology isn't ready for large models
```

## Architecture Decision: API Payment Flow

The README's core concept: "coins can be consumed via API calls."

### Design: Event-Driven Payment Bridge

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│   Consumer                                                   │
│   1. Calls APIGateway.requestCompute(taskParams)             │
│      - Transfers ROKO to escrow                              │
│      - Emits ComputeRequest(consumer, taskId, params, fee)   │
│                                                              │
│   Off-Chain Orchestrator (listens for events)                │
│   2. Receives ComputeRequest event                           │
│   3. Routes task to available miner(s)                       │
│   4. Miner executes computation                              │
│   5. Miner submits result hash on-chain                      │
│                                                              │
│   APIGateway Contract                                        │
│   6. Verifies result (via verification strategy)             │
│   7. Releases escrow to miner (minus protocol fee)           │
│   8. Emits ComputeResult(taskId, resultHash)                 │
│                                                              │
│   Consumer                                                   │
│   9. Reads result from IPFS/Arweave (referenced by hash)    │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Key Contract Interfaces

```solidity
interface IAPIGateway {
    struct Task {
        address consumer;
        bytes params;        // task parameters (or IPFS hash of large params)
        uint256 fee;         // ROKO tokens escrowed
        uint256 deadline;    // must complete by this block
        TaskStatus status;
    }
    
    function requestCompute(bytes calldata params, uint256 maxFee) external returns (uint256 taskId);
    function submitResult(uint256 taskId, bytes32 resultHash) external;  // miner submits
    function challengeResult(uint256 taskId) external;                   // anyone can challenge
    function claimTimeout(uint256 taskId) external;                      // consumer reclaims if deadline passes
    
    event ComputeRequested(address indexed consumer, uint256 indexed taskId, bytes params, uint256 fee);
    event ComputeCompleted(uint256 indexed taskId, bytes32 resultHash, address indexed miner);
    event ComputeChallenged(uint256 indexed taskId, address indexed challenger);
}

interface IComputeRegistry {
    function registerMiner(uint256 stakeAmount, bytes calldata capabilities) external;
    function deregisterMiner() external;
    function slashMiner(address miner, uint256 amount) external;  // governance/verification only
    
    event MinerRegistered(address indexed miner, uint256 stake, bytes capabilities);
    event MinerSlashed(address indexed miner, uint256 amount, string reason);
}
```

## Architecture Decision: Token Generation — Proof of Inference

**Core principle: ROKO tokens are minted by doing real work.** Running LLM inference generates coins. No arbitrary puzzle-solving — the "mining" IS the useful computation.

### Model A: Proof-of-Inference Minting (Preferred)

Tokens are minted as a direct byproduct of serving LLM inference requests.

```
Consumer submits inference request + payment (ETH/USDC/existing ROKO)
    ↓
Miner executes LLM inference (the actual useful work)
    ↓
Miner submits result + proof-of-work-done
    ↓
Contract verifies and mints fresh ROKO proportional to compute time
    ↓
Miner receives: newly minted ROKO + consumer's payment
Consumer receives: inference result + optionally some ROKO (incentive)
```

**How minting works:**
```solidity
struct InferenceReport {
    address miner;
    uint256 taskId;
    uint256 computeSeconds;   // verified wall-clock seconds of inference
    bytes32 resultHash;       // hash of the output
    bytes attestation;        // TEE attestation or validator signature
}

function settleInference(InferenceReport calldata report) external onlyVerifier {
    require(report.computeSeconds > 0, "No compute");
    
    // 1 ROKO = 1 second of processing time
    uint256 tokensToMint = report.computeSeconds * 1e18;
    
    _mint(report.miner, tokensToMint);
    
    emit InferenceMinted(report.miner, report.taskId, tokensToMint);
}
```

**The 1 ROKO = 1 second relationship:**
- Each ROKO represents a permanent, non-expiring claim on 1 second of network processing time
- As hardware improves, 1 second of processing time becomes more powerful — so the token's utility increases over time without needing to change the ratio
- This gives ROKO intrinsic value: it's not speculative, it's a compute voucher backed by real infrastructure

**Supply dynamics:**
```
Minting rate = Total inference seconds served per day × 1 ROKO/sec
              = (100 miners × 50,000 sec/day each) × 1
              = 5,000,000 ROKO/day

As network grows → more inference → more minting
As demand grows → ROKO used to pay for inference → absorption
Equilibrium: minting rate ≈ consumption rate
```

**The bootstrapping problem:** Early on, there are few consumers. Miners need incentive to provide inference capacity before demand exists. Solutions:
1. **Block rewards** — Mint ROKO for miners just for being online and available (like PoS staking rewards), even without consumer requests. Taper as demand grows.
2. **Self-consumption** — The protocol itself generates inference tasks (benchmarks, self-improvement training) that mint ROKO for early miners.
3. **Grants** — Pre-mint a founding allocation for early infrastructure providers.

### Model B: Pre-Minted Compute Vouchers (Fallback / Simpler)

If proof-of-inference verification is too complex for MVP, use a simpler model:

```
1. Pre-mint a large ROKO supply (e.g., 1 billion)
2. Each ROKO = 1 second of processing time, no expiration
3. Protocol treasury holds the supply
4. Miners earn ROKO from the treasury by serving inference
5. Consumers buy ROKO and spend it for API calls
```

```solidity
contract RokoToken is ERC20 {
    uint256 public constant INITIAL_SUPPLY = 1_000_000_000 * 1e18; // 1B tokens
    address public treasury;
    
    constructor(address _treasury) ERC20("Roko Coin", "ROKO") {
        treasury = _treasury;
        _mint(treasury, INITIAL_SUPPLY);
    }
}

contract ComputeGateway {
    IERC20 public roko;
    
    // Consumer spends ROKO for inference
    function requestInference(bytes calldata prompt, uint256 maxSeconds) external {
        uint256 cost = maxSeconds * 1e18; // 1 ROKO per second
        roko.transferFrom(msg.sender, address(this), cost);
        emit InferenceRequested(msg.sender, prompt, maxSeconds);
    }
    
    // Miner claims ROKO after delivering inference
    function claimReward(uint256 taskId, uint256 actualSeconds, bytes32 resultHash) external {
        // ... verification ...
        uint256 reward = actualSeconds * 1e18;
        roko.transfer(msg.sender, reward);
        // refund excess to consumer if actualSeconds < maxSeconds
    }
}
```

**Pros:** No complex minting logic, no inflation debate, ship faster
**Cons:** Fixed supply limits long-term growth; treasury is a centralization point

### The "1 Second" Problem: Hardware Normalization

A second of processing time on an A100 GPU ≠ a second on a 4090 ≠ a second on a CPU. You need a normalization unit.

**Options:**

| Approach | Description | Trade-off |
|---|---|---|
| **Wall-clock seconds on reference hardware** | Define "1 ROKO-second" as 1 second on a specific GPU class (e.g., A100-equivalent). Faster hardware earns tokens faster per wall-clock second. | Simple but requires benchmarking |
| **Token-per-token (LLM output)** | 1 ROKO = N output tokens of inference. Normalizes across hardware. | Clean for LLM, doesn't generalize to other compute |
| **Compute units (FLOPS)** | 1 ROKO = X teraFLOPS. Hardware-agnostic. | Hard to verify without TEE; easy to fake |
| **Benchmark-normalized** | Periodic benchmarks define hardware tiers. Tier multipliers adjust earnings. | Requires governance for benchmark updates |

**Recommendation:** Start with **token-per-token** for LLM workloads (1 ROKO = 1000 output tokens, or similar). It's the most natural unit for LLM inference, easy to meter, and hardware-agnostic. As the network expands to non-LLM compute, add compute-unit normalization.

### Revenue and Payment Flows

```
                    ┌─────────────────────┐
                    │   INFERENCE REQUEST  │
                    │   Consumer pays in:  │
                    │   - ROKO (preferred) │
                    │   - ETH/USDC (auto-  │
                    │     swapped to ROKO) │
                    └──────────┬──────────┘
                               ↓
              ┌────────────────┴────────────────┐
              ↓                                 ↓
    ┌─────────────────┐              ┌─────────────────┐
    │ Model A: Mint   │              │ Model B: Pay    │
    │ Consumer payment│              │ ROKO transfers  │
    │ goes to miner   │              │ from consumer   │
    │ PLUS fresh ROKO │              │ to miner via    │
    │ minted for work │              │ escrow contract │
    └────────┬────────┘              └────────┬────────┘
             ↓                                ↓
    ┌─────────────────────────────────────────────────┐
    │ In either model:                                │
    │   90% → Miner                                   │
    │    5% → Protocol treasury (development)         │
    │    5% → Entity treasury (self-directed fund)    │
    └─────────────────────────────────────────────────┘
```

**The entity treasury** (per the README) is the fund the AI entity uses for its own activities — investments, acquiring dedicated hardware, hiring additional compute. Initially governance-controlled; evolves toward agent autonomy as the system matures.

## Open Questions for Keith

1. **Chain selection:** Ethereum L2 (familiar tooling, Solidity) or Solana (better fit for high-frequency, AI ecosystem)? This affects everything downstream.

2. **Minting model:** Model A (proof-of-inference minting, more complex, true "mining") or Model B (pre-minted supply, simpler, ship faster)? Can start with B and migrate to A.

3. **Compute unit:** 1 ROKO = 1 second of wall-clock time, or 1 ROKO = N output tokens? The token-per-token model is cleaner for LLM but the "1 second" framing from the README has marketing appeal.

4. **The "entity" concept:** The README describes a self-directing AI entity that "accrues assets and revenue." This is essentially an AI agent with a treasury. How autonomous should this be on day 1? (Suggestion: start with a governance-controlled treasury, evolve toward agent autonomy.)

5. **Scope for MVP:** Token + single LLM inference endpoint + 3 miners + basic staking. Pre-minted supply (Model B). No marketplace, no governance, no self-directing entity yet. Graduate to Model A once verification is solid.

## Suggested Reading Order for Implementation

1. Re-read [06-token-standards.md](06-token-standards.md) — Decide ERC-20 vs ERC-1155
2. [07-dev-frameworks.md](07-dev-frameworks.md) — Set up Foundry
3. [05-solidity-guide.md](05-solidity-guide.md) — Write the token contract
4. [10-security-pitfalls.md](10-security-pitfalls.md) + [12-audit-patterns.md](12-audit-patterns.md) — Security-first mindset
5. [08-web3-frontend.md](08-web3-frontend.md) — Build the consumer interface
6. [16-ai-crypto-intersection.md](16-ai-crypto-intersection.md) — Design the verification layer

---
*Previous: [16-ai-crypto-intersection.md](16-ai-crypto-intersection.md)*
