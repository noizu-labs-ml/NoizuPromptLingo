# Blockchain Fundamentals

## What Is a Blockchain?

A blockchain is a distributed ledger — a database replicated across many computers where no single entity controls the truth. Instead of trusting a bank or server, you trust math and game theory.

**Core properties:**
- **Append-only** — You can add data but never modify or delete past entries
- **Distributed** — Every participant (node) holds a copy of the full ledger
- **Trustless** — You don't need to trust any individual participant; the protocol enforces honesty
- **Deterministic** — Given the same inputs, every node computes the same result

## The Anatomy of a Block

```
┌─────────────────────────────────┐
│ Block #1042                     │
├─────────────────────────────────┤
│ Previous Block Hash: 0x8a3f...  │  ← Links to block #1041
│ Timestamp: 1716825600           │
│ Nonce: 847291                   │  ← Only in PoW chains
│ Merkle Root: 0xc4e1...          │  ← Summary of all transactions
├─────────────────────────────────┤
│ Transactions:                   │
│   tx1: Alice → Bob  1.5 ETH    │
│   tx2: Carol → Dave 0.3 ETH    │
│   tx3: Contract deployment      │
│   ...                           │
├─────────────────────────────────┤
│ This Block Hash: 0x2b7d...      │  ← Hash of everything above
└─────────────────────────────────┘
```

Each block contains:
1. **Header** — metadata including the hash of the previous block (forming the "chain")
2. **Transaction list** — the actual operations recorded in this block
3. **Block hash** — a cryptographic fingerprint of the entire block

The previous-block-hash linkage is what makes the chain tamper-evident: changing any historical block changes its hash, which breaks the link to the next block, cascading forward and invalidating the entire chain from that point.

## How Transactions Work (Simplified)

1. **Alice signs a transaction** — "Send 1 ETH from my address to Bob's address," signed with her private key
2. **Transaction enters the mempool** — A waiting area of unconfirmed transactions visible to the network
3. **A validator/miner picks it up** — Includes it in a new block they're building
4. **The block is proposed** — The validator broadcasts the block to the network
5. **Other nodes verify** — They check: Is Alice's signature valid? Does she have enough ETH? Is the block correctly formed?
6. **Consensus** — Enough nodes agree the block is valid → it's added to the chain
7. **Finality** — After some confirmations (more blocks on top), the transaction is considered irreversible

## Key Concepts

### Addresses and Accounts

An **address** is derived from a public key, which is derived from a private key:

```
Private Key (secret)  →  Public Key  →  Address (public)
   256-bit random         secp256k1      last 20 bytes of
   number                 derivation     keccak256(pubkey)
```

- **Private key**: The secret that controls the account. Lose it = lose everything. No recovery.
- **Public key**: Derived from the private key. Used to verify signatures.
- **Address**: The "account number" others send funds to. Example: `0x742d35Cc6634C0532925a3b844Bc9e7595f2bD08`

On Ethereum there are two types of accounts:
- **EOA (Externally Owned Account)** — Controlled by a private key. This is what humans use.
- **Contract Account** — Controlled by code. Has an address but no private key. Executes when called.

### Gas (Ethereum)

Every operation on Ethereum costs **gas** — a unit measuring computational effort. You pay gas in ETH to compensate validators for running your transaction.

```
Transaction cost = Gas Used × Gas Price (in gwei)
                 = 21,000 × 30 gwei
                 = 630,000 gwei = 0.00063 ETH
```

- Simple ETH transfer: ~21,000 gas
- ERC-20 token transfer: ~65,000 gas
- Complex DeFi interaction: 200,000–500,000+ gas
- Deploying a contract: 1,000,000+ gas

Gas exists to prevent infinite loops and spam. If your transaction runs out of gas mid-execution, it reverts (undoes all changes) but you still pay for the gas consumed.

### Finality

Not all transactions are immediately permanent:

- **Probabilistic finality** (Bitcoin, PoW): Each new block on top makes reversal exponentially harder. Convention: 6 confirmations ≈ final.
- **Deterministic finality** (Tendermint/Cosmos, some PoS): Once 2/3 of validators sign off, the block is final. Period.
- **Ethereum**: Uses a hybrid — transactions are included in blocks, but "finalized" after 2 epochs (~12.8 minutes) under the Casper PoS protocol.

### Forks

When nodes disagree on the chain's state:
- **Soft fork** — Backward-compatible rule change. Old nodes still accept new blocks.
- **Hard fork** — Breaking change. Old nodes reject new blocks. The chain splits (e.g., Ethereum / Ethereum Classic).

## Ethereum vs. Bitcoin (Mental Model)

| | Bitcoin | Ethereum |
|---|---|---|
| Purpose | Digital money / store of value | Programmable money / world computer |
| Scripts | Very limited (Script language) | Turing-complete (Solidity, Vyper) |
| State | UTXO (unspent transaction outputs) | Account-based (balances + contract storage) |
| Block time | ~10 minutes | ~12 seconds |
| Consensus | Proof of Work | Proof of Stake (since Sept 2022, "The Merge") |

Bitcoin can be thought of as a calculator; Ethereum as a general-purpose computer that happens to also handle money.

## What Makes Blockchain Hard

The real challenges aren't the happy path — they're the constraints:

1. **Everything is public** — All transactions are visible to everyone. Privacy requires extra effort (ZK proofs, mixers).
2. **Immutability is a double-edged sword** — Deployed a buggy contract? It's there forever. You can't patch it in place.
3. **Gas costs real money** — Every operation costs ETH. Inefficient code literally costs users dollars.
4. **Composability creates attack surfaces** — Contracts call other contracts. A bug in one can cascade.
5. **No undo button** — Sent ETH to the wrong address? Called the wrong function? Tough luck.
6. **Speed vs. decentralization** — The more decentralized, the slower. This is the fundamental trilemma.

## The Blockchain Trilemma

Pick two:

```
        Decentralization
           /          \
          /            \
    Security ——————— Scalability
```

- **Decentralized + Secure** = Slow (Bitcoin, Ethereum L1)
- **Secure + Scalable** = Centralized (traditional databases, some L2s)
- **Decentralized + Scalable** = Security tradeoffs (some newer L1s)

Layer 2 solutions (rollups) try to get all three by inheriting L1 security while processing transactions off-chain. More on this in [13-layer2-scaling.md](13-layer2-scaling.md).

## Relevance to Rokos-Coin

The rokos-coin concept requires:
- **Token mechanics** (Level 2) — Representing compute rights as transferable tokens
- **Programmable payments** (Level 2) — API calls that consume tokens automatically
- **Economic incentives** (Level 5) — Miners providing computation for token rewards
- **Scalability** (Level 5) — High-frequency API calls can't each cost $2 in gas

These constraints will drive the chain selection decision — see [17-rokos-coin-design.md](17-rokos-coin-design.md).

---
*Next: [02-cryptographic-primitives.md](02-cryptographic-primitives.md)*
