# Rokos-Coin Crypto Training Library

A novice-to-expert knowledge base for blockchain development, smart contracts, and the Web3 ecosystem. Built specifically to support the rokos-coin project — a distributed AI computation token.

## Reading Order

Start at Level 1 and work through sequentially. Each level builds on the previous.

### Level 1 — Foundations (Start Here)
- [01-blockchain-fundamentals.md](01-blockchain-fundamentals.md) — What blockchains are, how they work, why they exist
- [02-cryptographic-primitives.md](02-cryptographic-primitives.md) — Hash functions, digital signatures, Merkle trees, elliptic curves
- [03-consensus-mechanisms.md](03-consensus-mechanisms.md) — PoW, PoS, BFT and how networks agree on truth

### Level 2 — Smart Contracts
- [04-smart-contracts-101.md](04-smart-contracts-101.md) — What contracts are, EVM model, gas, deployment
- [05-solidity-guide.md](05-solidity-guide.md) — Solidity language from zero, with patterns and pitfalls
- [06-token-standards.md](06-token-standards.md) — ERC-20, ERC-721, ERC-1155, ERC-4337 and when to use each

### Level 3 — Development Toolchain
- [07-dev-frameworks.md](07-dev-frameworks.md) — Hardhat, Foundry, testing, deployment workflows
- [08-web3-frontend.md](08-web3-frontend.md) — Connecting dApps to wallets: viem, wagmi, ethers.js
- [09-infrastructure.md](09-infrastructure.md) — RPC providers, indexers, storage, The Graph

### Level 4 — Security & Verification
- [10-security-pitfalls.md](10-security-pitfalls.md) — Reentrancy, flash loans, oracle manipulation, MEV, common exploits
- [11-security-tools.md](11-security-tools.md) — Slither, Mythril, Echidna, formal verification
- [12-audit-patterns.md](12-audit-patterns.md) — How to think about contract security, audit checklist

### Level 5 — Advanced Topics
- [13-layer2-scaling.md](13-layer2-scaling.md) — Rollups, L2s, cross-chain bridges
- [14-alternative-chains.md](14-alternative-chains.md) — Solana, Cosmos, Move-based chains, Rust contracts
- [15-defi-primitives.md](15-defi-primitives.md) — AMMs, lending, staking, oracles at the contract level
- [16-ai-crypto-intersection.md](16-ai-crypto-intersection.md) — Compute tokens, AI agents, decentralized inference

### Level 6 — Rokos-Coin Architecture
- [17-rokos-coin-design.md](17-rokos-coin-design.md) — Mapping the rokos-coin concept to concrete blockchain architecture

## How to Use This Library

- **Total beginner?** Start at 01, read linearly through Level 1-2. That gives you enough to read contract code.
- **Can read Solidity?** Skip to Level 3-4. The toolchain and security docs are where most projects fail.
- **Want to build rokos-coin?** Read everything, then focus on 16-17 for the AI×Crypto design decisions.
- **Each doc is self-contained** but links forward/back to related docs.
