# Smart Contracts 101

## What Is a Smart Contract?

Code that lives on a blockchain and executes automatically when called. Once deployed, nobody can change it (with caveats — see upgradeable patterns). It has its own address, can hold funds, and enforces rules without a middleman.

**Mental model:** A vending machine. You put in money, press a button, get a product. No cashier needed. The machine enforces the rules. Except this vending machine's rules are public, its cash register is visible to everyone, and nobody can unplug it.

## The EVM (Ethereum Virtual Machine)

The EVM is the runtime environment for smart contracts on Ethereum and all EVM-compatible chains (Arbitrum, Base, Polygon, BSC, Avalanche C-Chain, etc.).

```
Your Solidity Code
       ↓ (compile)
EVM Bytecode (low-level instructions)
       ↓ (deploy)
Lives at an address on-chain
       ↓ (call)
Every node executes the same bytecode, gets the same result
```

**Key properties:**
- **Deterministic** — Same input always produces same output on every node
- **Sandboxed** — Contracts can't access the filesystem, network, or anything outside the EVM
- **Metered** — Every operation costs gas; infinite loops are impossible (you run out of gas)
- **Stack-based** — 256-bit word size, 1024 stack depth

## Contract Lifecycle

### 1. Write

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SimpleStore {
    uint256 private _value;

    event ValueChanged(uint256 newValue);

    function store(uint256 newValue) external {
        _value = newValue;
        emit ValueChanged(newValue);
    }

    function retrieve() external view returns (uint256) {
        return _value;
    }
}
```

### 2. Compile

The Solidity compiler (`solc`) produces:
- **Bytecode** — The actual machine code deployed to the chain
- **ABI (Application Binary Interface)** — A JSON description of the contract's functions, events, and types. This is how frontend code knows how to call the contract.

### 3. Deploy

Deploying is a special transaction with no `to` address. The bytecode becomes the contract code at a new address. You pay gas proportional to the bytecode size.

### 4. Interact

Two types of interactions:
- **Read (view/pure functions)** — Free. Doesn't change state. Runs locally on your node.
- **Write (state-changing functions)** — Costs gas. Creates a transaction. Waits for block confirmation.

## Gas Deep Dive

Every EVM operation has a gas cost:

| Operation | Gas Cost | Notes |
|---|---|---|
| ADD, SUB | 3 | Arithmetic |
| MUL, DIV | 5 | |
| SLOAD (read storage) | 2,100 (cold) / 100 (warm) | First access is expensive |
| SSTORE (write storage) | 20,000 (new) / 5,000 (update) | Storage is the most expensive operation |
| CALL (external call) | 2,600 (cold) | Calling another contract |
| LOG (emit event) | 375 + 375/topic | Events are cheaper than storage |
| CREATE (deploy) | 32,000 + bytecode cost | Deploying a new contract |

**EIP-1559 fee model (current):**
```
Total fee = (Base Fee + Priority Fee) × Gas Used

Base Fee:    Set by the protocol, adjusts based on block fullness. Burned.
Priority Fee: Your tip to the validator. Higher tip = faster inclusion.
Gas Limit:   Maximum gas you're willing to spend. Unused gas is refunded.
```

If your transaction runs out of gas mid-execution:
- All state changes revert (as if the transaction never happened)
- But you still pay for all the gas consumed up to that point
- This is why gas estimation matters

## Contract Storage Model

Each contract has a 2^256 slot storage space. Slots are 32 bytes each.

```solidity
contract Storage {
    uint256 a;      // slot 0
    uint256 b;      // slot 1
    uint128 c;      // slot 2 (left half)
    uint128 d;      // slot 2 (right half — packed!)
    
    mapping(address => uint256) balances;  // slot 3 (but values stored at keccak256(key . slot))
    uint256[] items;                        // slot 4 (length), elements at keccak256(4) + index
}
```

**Storage packing:** The EVM reads/writes in 32-byte chunks. Variables smaller than 32 bytes are packed into the same slot if they fit. This saves gas on reads/writes.

**Why this matters:** Every storage read costs 2,100 gas (cold). Every write costs 5,000-20,000 gas. Designing your storage layout is a major gas optimization lever.

## Events and Logs

Events are the blockchain's way of emitting structured data that's cheap to write but not readable by other contracts.

```solidity
event Transfer(address indexed from, address indexed to, uint256 value);

// Emitting:
emit Transfer(msg.sender, recipient, amount);
```

- **Indexed parameters** (up to 3) — Stored as "topics," searchable/filterable
- **Non-indexed parameters** — Stored in data, cheaper but not directly searchable
- **Use cases:** Frontend notifications, off-chain indexing (The Graph), audit trails
- **Key limitation:** Contracts cannot read events. They're write-only from the contract's perspective.

## External Calls and Composability

Contracts can call other contracts. This is what makes DeFi possible — protocols build on top of each other.

```solidity
// Calling an external contract
IERC20(tokenAddress).transfer(recipient, amount);

// Low-level call (more dangerous, more flexible)
(bool success, bytes memory data) = target.call(abi.encodeWithSignature("doSomething(uint256)", 42));
require(success, "Call failed");
```

**The double-edged sword:** Composability means a contract can interact with any other contract. This creates:
- **Positive:** Lego-like building (swap on Uniswap → lend on Aave → borrow → all in one transaction)
- **Negative:** Attack surface (reentrancy, flash loan exploits, unexpected callbacks)

## Upgradeable Contracts

Deployed contracts are immutable. But there's a pattern to achieve "upgrades":

```
User → Proxy Contract (stores state, delegates calls) → Implementation Contract (has the logic)
                                                          ↓ (upgrade)
                                                        New Implementation Contract
```

**Proxy patterns:**
- **Transparent Proxy** — Admin calls go to proxy logic; user calls are delegated. OpenZeppelin standard.
- **UUPS (Universal Upgradeable Proxy Standard)** — Upgrade logic lives in the implementation. Lighter weight.
- **Diamond (EIP-2535)** — Multiple implementation contracts ("facets"). Complex but powerful.

**Dangers:**
- Storage layout collisions between proxy and implementation
- Uninitialized implementation contracts (attacker can call `initialize()`)
- Governance risks (who controls upgrades?)

## What Contracts Can't Do

- **No network access** — Can't call APIs, fetch URLs, or access external data directly
- **No randomness** — `block.timestamp` and `block.number` are manipulable by validators. Use Chainlink VRF for secure randomness.
- **No scheduling** — Contracts can't trigger themselves. Need external keepers (Chainlink Automation, Gelato).
- **No floating point** — EVM has only integer math. Use fixed-point representations (e.g., 18 decimals for token amounts).
- **No secrets** — All storage is publicly readable, even `private` variables. "Private" just means other contracts can't read it.

## Relevance to Rokos-Coin

The token contract itself is straightforward (ERC-20 with custom mechanics). The interesting parts:
- **API payment logic** — Contract that accepts tokens and emits events triggering off-chain compute
- **Miner rewards** — Contract that distributes tokens based on verified computation
- **Compute verification** — The hard problem. How does the contract know the miner actually did the work? (See [16-ai-crypto-intersection.md](16-ai-crypto-intersection.md))

---
*Previous: [03-consensus-mechanisms.md](03-consensus-mechanisms.md) | Next: [05-solidity-guide.md](05-solidity-guide.md)*
