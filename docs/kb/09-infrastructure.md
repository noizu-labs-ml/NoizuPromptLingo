# Web3 Infrastructure

The backend services that make dApps work.

## RPC Providers

Your dApp needs a node to read blockchain state and submit transactions. Running your own is expensive and complex. Managed providers handle it.

### The Major Providers (2026)

| Provider | Strengths | Free Tier | Pricing Model |
|---|---|---|---|
| **Alchemy** | Best dev tools, Notify API, Transact API | 30M compute units/month | Compute unit based |
| **Infura** | Powers MetaMask, ConsenSys ecosystem | 100K requests/day | Request based |
| **QuickNode** | 80+ chains, enterprise SLA | Limited | Flat rate ($799/mo for 75 RPS) |
| **Chainstack** | Good multi-chain support | 25K requests/day | Tiered |
| **Ankr** | Cheapest, decentralized option | Public endpoints | Per-request |

**Best practice:** Use at least two providers with automated failover. If Alchemy goes down, your dApp shouldn't.

```typescript
import { createPublicClient, http, fallback } from 'viem';

const client = createPublicClient({
    chain: mainnet,
    transport: fallback([
        http('https://eth-mainnet.g.alchemy.com/v2/KEY1'),
        http('https://mainnet.infura.io/v3/KEY2'),
    ]),
});
```

### What RPC Calls Look Like

```
POST https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY
{
    "jsonrpc": "2.0",
    "method": "eth_getBalance",
    "params": ["0x742d35Cc...", "latest"],
    "id": 1
}
```

Common methods:
- `eth_getBalance` — Account ETH balance
- `eth_call` — Read-only contract call (free)
- `eth_sendRawTransaction` — Submit a signed transaction
- `eth_getTransactionReceipt` — Check if a tx was mined
- `eth_getLogs` — Query event logs (filtered by address, topics, block range)
- `eth_getStorageAt` — Read raw storage slot (yes, even "private" variables)

## Indexing: The Graph

**The problem:** Querying historical blockchain data via RPC is painful. Want "all transfers of token X in the last 30 days"? That requires scanning every block.

**The Graph** solves this by letting you define a **subgraph** — a schema that indexes specific contract events into a queryable GraphQL API.

### How It Works

1. **Define a schema** — What entities do you want to track?
```graphql
type Transfer @entity {
    id: ID!
    from: Bytes!
    to: Bytes!
    value: BigInt!
    timestamp: BigInt!
    block: BigInt!
}
```

2. **Write mappings** — AssemblyScript handlers that process events:
```typescript
export function handleTransfer(event: TransferEvent): void {
    let transfer = new Transfer(event.transaction.hash.toHex());
    transfer.from = event.params.from;
    transfer.to = event.params.to;
    transfer.value = event.params.value;
    transfer.timestamp = event.block.timestamp;
    transfer.block = event.block.number;
    transfer.save();
}
```

3. **Deploy** — The Graph indexes your contract's events and serves a GraphQL endpoint.

4. **Query:**
```graphql
{
    transfers(first: 10, orderBy: timestamp, orderDirection: desc) {
        from
        to
        value
        timestamp
    }
}
```

**2026 developments:** The Graph is expanding into a modular data layer — Token API (pre-indexed token data), Tycho (real-time DeFi liquidity), AI-native query access.

## Decentralized Storage

Blockchain stores code and state. Large data (images, metadata, documents) goes to decentralized storage.

### IPFS (InterPlanetary File System)

Content-addressed peer-to-peer protocol. Files are referenced by their hash (CID), not by location.

```
Traditional:  https://example.com/image.png     (location-addressed — can change)
IPFS:         ipfs://QmYwAPJzv5CZsnA625s3Xf2...  (content-addressed — immutable)
```

**Key behavior:** IPFS doesn't guarantee persistence. If no node "pins" your file, it gets garbage collected. Use a pinning service:
- **Pinata** — Managed IPFS pinning, generous free tier
- **web3.storage** — Free IPFS + Filecoin persistence

### Arweave

Pay once (~$0.01-$0.03 per MB), stored permanently via an endowment fund model. The "permanent web."

**Use when:** Data must survive indefinitely (contract source code, NFT assets, legal documents).

### Filecoin

Incentive layer on IPFS. Storage providers earn FIL tokens for provably storing data. Think "decentralized AWS S3."

### Practical Pattern (2026)

```
Hot data (fast access)  → IPFS with pinning service
Redundancy              → Filecoin deals
Permanent archive       → Arweave mirror
```

## Oracles: Off-Chain Data On-Chain

Smart contracts can't access external data (APIs, prices, weather, etc.). Oracles bridge this gap.

### Chainlink

The dominant oracle network. A decentralized network of nodes that fetch and aggregate external data.

**Price Feeds:**
```solidity
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

function getETHPrice() public view returns (int256) {
    AggregatorV3Interface feed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    (, int256 price,,,) = feed.latestRoundData();
    return price;  // ETH/USD with 8 decimals
}
```

**Chainlink services:**
| Service | Purpose |
|---|---|
| Price Feeds | Real-time asset prices (DeFi essential) |
| VRF | Verifiable random numbers (gaming, lotteries) |
| Automation (Keepers) | Scheduled contract execution |
| Functions | Call any API from a smart contract |
| CCIP | Cross-chain messaging |

### Pyth Network

Preferred on Solana and newer chains. Pull-based model (consumers fetch prices on-demand) vs. Chainlink's push model. Lower latency, better for high-frequency applications.

### Oracle Manipulation — The #1 DeFi Attack Vector

If your contract uses a price oracle, attackers will try to manipulate it:
- **Flash loan + thin-pool manipulation** — Borrow massive capital, manipulate a low-liquidity price source, drain your protocol
- **Mitigation:** Use TWAP (time-weighted average prices), multiple oracle sources, staleness checks

## ENS (Ethereum Name Service)

Human-readable names for Ethereum addresses: `vitalik.eth` → `0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045`

Also supports: content hashes (IPFS/Arweave), text records, subdomains. Useful for user-friendly payment addresses and decentralized website hosting.

## Relevance to Rokos-Coin

The infrastructure stack for rokos-coin likely needs:
- **RPC provider** — For the dApp frontend and any off-chain indexing
- **The Graph subgraph** — Index compute requests, miner registrations, reward distributions
- **IPFS/Arweave** — Store computation task specifications and results
- **Oracle** — Report computation verification results on-chain (or use a custom verification network)
- **Chainlink Automation** — Trigger periodic reward distributions or task assignments

---
*Previous: [08-web3-frontend.md](08-web3-frontend.md) | Next: [10-security-pitfalls.md](10-security-pitfalls.md)*
