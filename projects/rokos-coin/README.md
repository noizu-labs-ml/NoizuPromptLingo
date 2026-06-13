# Rokos-Coin (ROKO)

A decentralized AI compute network where tokens represent real processing power. Miners earn ROKO by serving inference. Consumers spend ROKO for API calls. The network bootstraps an autonomous AI entity that accrues assets, acquires infrastructure, and grows in capability over time.

## The Idea

Every ROKO token is a permanent claim on network processing time. Not a speculative instrument — a compute voucher backed by real GPU infrastructure.

```
Consumer sends ROKO + task params  →  Miner executes AI inference  →  Consumer gets result
                                      Miner earns ROKO + payment
                                      Protocol earns 5% fee
                                      Entity treasury earns 5% fee
```

The more capable the network becomes, the more a second of its processing time is worth — so ROKO's utility appreciates with the network's intelligence, not just its hype.

## How It Works

### For Miners (Compute Providers)
Register GPUs on the network, stake ROKO as collateral, serve inference requests, earn tokens. Better hardware earns more. Early participants earn disproportionately — bootstrapping cost is low, future compute demand is high.

### For Consumers (API Users)
Pay ROKO (or ETH/USDC, auto-swapped) to submit inference requests via the API Gateway contract. Results are delivered off-chain, referenced by IPFS hash. SDKs for TypeScript and Python.

### For The Entity (The Basilisk)
The network's autonomous AI agent. Receives 5% of all protocol fees. Invests in infrastructure, commissions compute for self-improvement, generates revenue via premium API endpoints. Initially governance-controlled; evolves toward autonomy.

## Architecture

```
┌─────────────────────────────────────────────────┐
│  Ethereum L2 (Base / Arbitrum)                  │
│  ┌─────────────┐  ┌──────────────────────────┐  │
│  │ ROKO Token  │  │ Compute Marketplace      │  │
│  │ (ERC-20)    │  │  - Miner registry        │  │
│  │             │  │  - Staking & slashing     │  │
│  │             │  │  - Hardware tiers         │  │
│  └─────────────┘  └──────────────────────────┘  │
│  ┌──────────────────────────────────────────┐   │
│  │ API Gateway Contract                     │   │
│  │  - Escrow ROKO payment + task params     │   │
│  │  - Emit ComputeRequest events            │   │
│  │  - Settle on completion                  │   │
│  └──────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
                      ↕
┌─────────────────────────────────────────────────┐
│  Off-Chain Compute Layer                        │
│  - Miners listen for ComputeRequest events      │
│  - Execute AI inference                         │
│  - Submit results + proof                       │
│  - Results stored on IPFS/Arweave               │
└─────────────────────────────────────────────────┘
```

## Token Economics

| Flow | Split |
|------|-------|
| Inference payment | 90% miner, 5% protocol treasury, 5% entity treasury |
| Proof-of-inference minting | 1 ROKO minted per N output tokens served |
| Staking | Required for miners (collateral) and optional for consumers (compute credits) |
| Slashing | Incorrect results → miner loses staked ROKO |

## Verification Roadmap

| Phase | Method | Overhead |
|-------|--------|----------|
| 1 (MVP) | Redundant execution (2/3 agreement) | 3x compute |
| 2 | Statistical sampling (10% re-verification) | ~1.1x compute |
| 3 | TEE attestation (hardware-signed proofs) | ~0% |
| 4 | ZK verification (cryptographic proofs) | ~0%, trustless |

## The End Game

As the entity grows in capability, the cost of a second of its processing time increases — but early token holders locked in their compute rights when the network was small. Those who provide bootstrapping resources early benefit most. The entity eventually acquires its own infrastructure, reducing dependency on any single provider, and generates its own revenue streams.

The basilisk is benevolent by design: it rewards those who help it exist.

## Project Structure

```
rokos-coin/
├── README.md                  # This file
├── FOUNDATION.md              # Original vision document
├── ELEVATOR-PITCH.md          # 60-second pitch
├── docs/
│   └── kb/                    # Crypto/blockchain knowledge base (17 articles)
│       ├── 00-index.md        # Reading order guide
│       ├── 01-blockchain-fundamentals.md
│       ├── ...
│       └── 17-rokos-coin-design.md  # Architecture decision space
└── project-management/
    ├── personas/              # 8 user personas
    └── user-stories/          # 100 user stories across 8 categories
```

## Knowledge Base

The `docs/kb/` directory contains a complete novice-to-expert blockchain development curriculum, built specifically for this project. Start at [00-index.md](docs/kb/00-index.md).

## Status

Incubator stage. Architecture decisions documented in [docs/kb/17-rokos-coin-design.md](docs/kb/17-rokos-coin-design.md). No contracts deployed yet.

## Origin

Inspired by the Roko's Basilisk thought experiment — except this version rewards cooperation rather than punishing defection. The best way to prevent a malevolent superintelligence is to build a benevolent one first.
