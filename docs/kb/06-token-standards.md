# Token Standards

Tokens are smart contracts that follow a standard interface so wallets, exchanges, and other contracts can interact with them uniformly.

## ERC-20: Fungible Tokens

The foundation. Every token you've heard of (USDC, LINK, UNI, etc.) is an ERC-20.

**"Fungible"** = interchangeable. One USDC is identical to any other USDC, just like one dollar bill is identical to another.

### Interface

```solidity
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
```

### The Approve/TransferFrom Pattern

Why two-step transfers? Because contracts can't receive tokens and react in the same transaction (unlike ETH with `receive()`).

```
Step 1: Alice calls token.approve(DEX, 100)
        → "DEX contract is allowed to spend up to 100 of my tokens"

Step 2: Alice calls DEX.swap(token, 100)
        → DEX internally calls token.transferFrom(Alice, DEX, 100)
```

**Pitfall: Approval phishing.** If Alice approves a malicious contract for `type(uint256).max`, that contract can drain all her tokens at any time. This is the most common wallet drain attack vector.

**ERC-2612 (Permit):** Solves the two-transaction UX by letting users sign an off-chain approval message. The spender submits the signature in the same transaction as the transfer. One transaction instead of two. Widely adopted.

### Decimals

Tokens don't have decimal points — they use integer math with an implicit decimal position:

```
Token has 18 decimals (standard for most ERC-20s)
1 TOKEN = 1_000_000_000_000_000_000 (1e18) in the contract
0.5 TOKEN = 500_000_000_000_000_000

USDC has 6 decimals
1 USDC = 1_000_000 in the contract
```

Always check `decimals()` when doing cross-token math.

### Minimal ERC-20 Token

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RokoToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Roko Coin", "ROKO") {
        _mint(msg.sender, initialSupply * 10**decimals());
    }
}
```

That's a fully functional, standards-compliant token in 8 lines.

## ERC-721: Non-Fungible Tokens (NFTs)

Each token is unique, identified by a `tokenId`. PFP collections, game items, real estate deeds, etc.

```solidity
interface IERC721 {
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
}
```

**Key difference from ERC-20:** Ownership is per-token-ID, not per-balance. You own specific token #42, not "42 tokens."

**Metadata:** Typically stored off-chain (IPFS, Arweave). The contract stores a `tokenURI` pointing to a JSON file with name, description, image URL, attributes.

## ERC-1155: Multi-Token Standard

Combines fungible and non-fungible tokens in one contract. Efficient for games and collections where you have both currencies (fungible) and unique items (non-fungible).

```solidity
// One contract handles multiple token types
balanceOf(player, GOLD_ID)      // → 5000 (fungible)
balanceOf(player, SWORD_ID)     // → 1 (non-fungible)
balanceOf(player, POTION_ID)    // → 25 (semi-fungible)
```

**Advantages over separate ERC-20 + ERC-721:**
- Batch transfers (move 10 different items in one transaction)
- Single contract deployment (cheaper)
- Atomic operations across token types

## ERC-4337: Account Abstraction

Not a token standard — a protocol for making smart contract wallets first-class citizens. This is transforming how users interact with blockchain.

**The problem it solves:** EOAs (regular wallets) require users to hold ETH for gas, manage seed phrases, and can't enforce custom security rules.

**What ERC-4337 enables:**
- **Gas sponsorship** — Someone else pays your gas fees (onboarding without ETH)
- **Batched transactions** — Approve + swap in one click
- **Social recovery** — Recover your wallet via trusted contacts
- **Session keys** — Pre-authorize a dApp for N transactions without signing each one
- **Custom validation** — Multisig, biometric, or any custom auth logic

**How it works:**
```
User creates a UserOperation (not a regular transaction)
    ↓
Bundler collects UserOperations from a separate mempool
    ↓
Bundler submits a batch to the EntryPoint contract
    ↓
EntryPoint calls each user's smart contract wallet to validate and execute
    ↓
Paymaster optionally sponsors gas
```

**Scale (2026):** 40M+ smart accounts, 100M+ UserOperations executed.

**EIP-7702 (live since Pectra, May 2025):** Complements 4337 by letting regular EOAs temporarily act as smart contract wallets. Bridges the gap for existing users.

## ERC-6900 / ERC-7579: Modular Smart Accounts

Extends account abstraction with a plugin architecture for smart wallets:
- Install/uninstall modules (e.g., add 2FA, spending limits, auto-invest)
- Standardized module interface across wallet providers
- Growing ecosystem of reusable security and UX modules

## Which Standard for Rokos-Coin?

**The token itself:** ERC-20 is the right base. Roko coins are fungible — one compute-right unit is the same as another.

**Extensions to consider:**
- **ERC-2612 (Permit)** — Gasless approvals for API payment flows
- **ERC-4337 integration** — Let the network sponsor gas for API consumers (they pay in ROKO tokens, not ETH)
- **Custom transfer hooks** — Deduct compute credits on transfer-to-API-address
- **Possibly ERC-1155** — If different tiers of compute rights (priority levels, GPU vs CPU) should be separate token types

---
*Previous: [05-solidity-guide.md](05-solidity-guide.md) | Next: [07-dev-frameworks.md](07-dev-frameworks.md)*
