# Solidity Language Guide

Solidity is the dominant smart contract language for EVM chains. Current stable version: **v0.8.35** (April 2026).

## The Basics

### Data Types

```solidity
// Value types
bool flag = true;
uint256 amount = 1000;          // unsigned 256-bit integer (0 to 2^256-1)
int256 delta = -50;             // signed 256-bit integer
address wallet = 0x742d35Cc6634C0532925a3b844Bc9e7595f2bD08;
address payable recipient;       // can receive ETH via .transfer() or .send()
bytes32 hash;                    // fixed-size byte array
bytes data;                      // dynamic byte array
string name = "Roko";           // UTF-8 string (expensive on-chain — avoid long strings)

// Smaller types exist (uint8, uint128, etc.) — useful for storage packing
uint128 a;
uint128 b;  // a and b share one 32-byte storage slot

// Enums
enum Status { Pending, Active, Completed }

// Structs
struct Miner {
    address wallet;
    uint256 computeUnits;
    uint256 lastRewardBlock;
}
```

### Visibility

```solidity
function publicFn() public { }     // callable by anyone, including other contracts
function externalFn() external { }  // callable only from outside (not by this contract internally)
function internalFn() internal { }  // callable by this contract and derived contracts
function privateFn() private { }    // callable only by this contract
```

**Rule of thumb:** Use `external` for functions only called from outside (cheaper gas than `public` for complex args). Use `internal` for shared logic. Use `private` rarely.

### State Mutability

```solidity
function read() external view returns (uint256) { }  // reads state, doesn't modify
function compute() external pure returns (uint256) { }  // doesn't read or modify state
function write() external { }  // modifies state (costs gas)
function deposit() external payable { }  // can receive ETH
```

### Mappings

The most-used data structure. A key-value store where every possible key exists (defaults to zero/false/empty).

```solidity
mapping(address => uint256) public balances;
mapping(address => mapping(address => uint256)) public allowances;  // nested

// Usage
balances[msg.sender] = 100;
uint256 bal = balances[someAddress];  // returns 0 if never set

// IMPORTANT: You cannot iterate over a mapping. No .length, no .keys().
// If you need iteration, maintain a separate array of keys.
```

### Arrays

```solidity
uint256[] public items;              // dynamic array (storage)
uint256[10] public fixedItems;       // fixed-size array

items.push(42);                      // append
items.pop();                         // remove last
uint256 len = items.length;
delete items[2];                     // sets to 0, doesn't shrink array
```

**Warning:** Iterating over unbounded arrays in a transaction can hit the gas limit. Design with bounded operations.

## Essential Patterns

### The Constructor

```solidity
contract Token {
    address public owner;
    
    constructor(string memory name, uint256 initialSupply) {
        owner = msg.sender;  // deployer becomes owner
    }
}
```

Runs exactly once, at deployment. Cannot be called again.

### Modifiers

```solidity
modifier onlyOwner() {
    require(msg.sender == owner, "Not owner");
    _;  // placeholder for the function body
}

function mint(uint256 amount) external onlyOwner {
    // only owner can call this
}
```

### Error Handling

```solidity
// Custom errors (gas-efficient — recommended since Solidity 0.8.4)
error InsufficientBalance(uint256 available, uint256 required);
error Unauthorized();

function withdraw(uint256 amount) external {
    if (balances[msg.sender] < amount) {
        revert InsufficientBalance(balances[msg.sender], amount);
    }
    // ...
}

// require (older style, still common)
require(amount > 0, "Amount must be positive");

// assert (for invariants that should NEVER be false)
assert(totalSupply == sumOfAllBalances);
```

### Receive and Fallback

```solidity
// Called when ETH is sent to this contract with no data
receive() external payable {
    emit Received(msg.sender, msg.value);
}

// Called when no function matches the call data, or when ETH is sent with data
fallback() external payable {
    // often used in proxy patterns
}
```

### Events

```solidity
event Transfer(address indexed from, address indexed to, uint256 value);
event ComputeRequested(address indexed requester, uint256 indexed taskId, bytes params);

function transfer(address to, uint256 value) external {
    // ... logic ...
    emit Transfer(msg.sender, to, value);
}
```

Events are the primary way to communicate with off-chain systems. They're indexed by The Graph, read by frontends, and used for debugging. Cheap to emit (~375 gas + 375 per indexed topic + 8 per byte of data).

## Common Pitfalls

### 1. Reentrancy

The #1 smart contract vulnerability. Total losses: $420M+ through 2025.

```solidity
// VULNERABLE
function withdraw() external {
    uint256 amount = balances[msg.sender];
    (bool success, ) = msg.sender.call{value: amount}("");  // ← attacker's receive() calls withdraw() again
    require(success);
    balances[msg.sender] = 0;  // ← too late, already drained
}

// SAFE — Checks-Effects-Interactions pattern
function withdraw() external {
    uint256 amount = balances[msg.sender];
    balances[msg.sender] = 0;              // 1. Effect (update state FIRST)
    (bool success, ) = msg.sender.call{value: amount}("");  // 2. Interaction (external call LAST)
    require(success);
}
```

Or use OpenZeppelin's `ReentrancyGuard`:
```solidity
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Safe is ReentrancyGuard {
    function withdraw() external nonReentrant {
        // safe from reentrancy
    }
}
```

### 2. Integer Overflow/Underflow

Solidity 0.8+ has checked arithmetic by default — operations revert on overflow. But `unchecked` blocks remove this protection:

```solidity
unchecked {
    uint8 x = 255;
    x++;  // wraps to 0! No revert.
}
```

Only use `unchecked` when you've mathematically proven overflow is impossible (e.g., loop counters bounded by array length).

### 3. tx.origin vs msg.sender

```solidity
// DANGEROUS — tx.origin is the original external caller, not the immediate caller
require(tx.origin == owner);  // ← phishing attack: trick owner into calling malicious contract

// SAFE
require(msg.sender == owner);  // ← msg.sender is the direct caller
```

### 4. Private Doesn't Mean Secret

```solidity
uint256 private secretKey = 12345;  // visible to ANYONE who reads the blockchain storage
```

`private` only prevents other contracts from reading it via Solidity. Anyone can read any storage slot directly via `eth_getStorageAt`.

### 5. Timestamp Dependence

```solidity
// SOMEWHAT DANGEROUS — validators can manipulate by a few seconds
require(block.timestamp > deadline);

// SAFER for time-sensitive operations — use block numbers or commit-reveal schemes
```

## The OpenZeppelin Standard Library

OpenZeppelin Contracts v5.x is the de facto standard library. Use it — don't reinvent these wheels.

```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract RokoToken is ERC20, Ownable, ReentrancyGuard {
    constructor() ERC20("Roko Coin", "ROKO") Ownable(msg.sender) {
        _mint(msg.sender, 1_000_000 * 10**decimals());
    }
}
```

**Key OZ modules:**
| Module | Purpose |
|---|---|
| `ERC20`, `ERC721`, `ERC1155` | Token implementations |
| `Ownable`, `AccessControl` | Role-based access |
| `ReentrancyGuard` | Reentrancy protection |
| `SafeERC20` | Safe token transfers (handles non-compliant tokens) |
| `MerkleProof` | Verify Merkle proofs (airdrop allowlists) |
| `Governor`, `TimelockController` | On-chain governance |
| `TransparentUpgradeableProxy`, `UUPSUpgradeable` | Proxy patterns |

## Gas Optimization Cheat Sheet

| Technique | Savings | Example |
|---|---|---|
| Pack storage variables | High | `uint128 a; uint128 b;` (one slot) vs `uint256 a; uint256 b;` (two slots) |
| Use `calldata` for read-only args | Medium-High | `function f(uint256[] calldata ids)` vs `memory` |
| Cache storage reads | High | `uint256 cached = _value; use(cached); use(cached);` |
| Custom errors | Medium | `error X()` vs `require(false, "long string")` |
| `unchecked` for safe math | Low-Medium | Loop counters where overflow is impossible |
| Events over storage | High | Store only what contracts need to read; emit the rest |
| Short-circuit conditions | Low | Cheapest check first in `if` chains |
| Avoid redundant SLOADs | High | Every cold storage read = 2,100 gas |

---
*Previous: [04-smart-contracts-101.md](04-smart-contracts-101.md) | Next: [06-token-standards.md](06-token-standards.md)*
