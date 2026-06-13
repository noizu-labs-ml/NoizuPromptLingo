# Development Frameworks & Toolchain

## The Two Frameworks That Matter (2026)

### Foundry (Recommended for New Projects)

A Rust-based toolkit. Tests are written in Solidity, compile and run fast.

**Components:**
- `forge` — Build, test, fuzz, deploy
- `cast` — CLI for interacting with contracts and chains
- `anvil` — Local Ethereum node (like Ganache but fast)
- `chisel` — Solidity REPL

**Install:**
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

**Project structure:**
```
my-project/
├── src/           # Contract source files
├── test/          # Test files (Solidity)
├── script/        # Deployment scripts (Solidity)
├── lib/           # Dependencies (git submodules)
├── foundry.toml   # Configuration
└── remappings.txt # Import path remappings
```

**Why Foundry:**
- 5-10x faster test execution than Hardhat
- Fuzz testing is built-in (not a plugin)
- Tests are Solidity, so you think in the same language as the contract
- `forge coverage` for line/branch coverage
- `forge snapshot` for gas benchmarking
- `forge verify-contract` for Etherscan verification
- Growing market share (~30% and accelerating)

**Example test:**
```solidity
// test/Token.t.sol
import "forge-std/Test.sol";
import "../src/Token.sol";

contract TokenTest is Test {
    Token token;
    address alice = makeAddr("alice");

    function setUp() public {
        token = new Token(1_000_000e18);
    }

    function test_transfer() public {
        token.transfer(alice, 100e18);
        assertEq(token.balanceOf(alice), 100e18);
    }

    // Fuzz test — Foundry generates random inputs
    function testFuzz_transfer(uint256 amount) public {
        amount = bound(amount, 0, token.balanceOf(address(this)));
        token.transfer(alice, amount);
        assertEq(token.balanceOf(alice), amount);
    }
}
```

**Run tests:**
```bash
forge test                    # run all tests
forge test -vvvv              # verbose (show call traces)
forge test --match-test test_transfer  # run specific test
forge test --gas-report       # show gas usage per function
forge coverage                # line/branch coverage
```

### Hardhat

The JavaScript/TypeScript toolkit. Dominant ecosystem (~60% of projects) but losing ground to Foundry.

**Install:**
```bash
mkdir my-project && cd my-project
npm init -y
npm install --save-dev hardhat
npx hardhat init
```

**Project structure:**
```
my-project/
├── contracts/     # Contract source files
├── test/          # Test files (JS/TS)
├── scripts/       # Deployment scripts
├── hardhat.config.ts
└── package.json
```

**Why Hardhat:**
- Better debugging UX (`console.log` in Solidity!)
- Rich plugin ecosystem (gas reporter, coverage, Etherscan verify)
- Familiar if you're from the JS/TS world
- Better deployment scripting (Hardhat Ignition for declarative deploys)
- More tutorials, Stack Overflow answers, and example code

**Example test:**
```typescript
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Token", function () {
    it("should transfer tokens", async function () {
        const [owner, alice] = await ethers.getSigners();
        const Token = await ethers.getContractFactory("Token");
        const token = await Token.deploy(1_000_000n * 10n ** 18n);

        await token.transfer(alice.address, 100n * 10n ** 18n);
        expect(await token.balanceOf(alice.address)).to.equal(100n * 10n ** 18n);
    });
});
```

### Practical Recommendation

Use **Foundry** for contract development and testing. Use **Hardhat** if you need complex deployment scripts or are more comfortable in TypeScript. Many serious projects use both.

## Dependency Management

**Foundry:** Uses git submodules via `forge install`.
```bash
forge install OpenZeppelin/openzeppelin-contracts
# Creates lib/openzeppelin-contracts/
```

**Hardhat:** Uses npm.
```bash
npm install @openzeppelin/contracts
```

## Local Development Chain

**Anvil (Foundry):**
```bash
anvil                          # starts local chain at http://localhost:8545
anvil --fork-url https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY  # fork mainnet
```

**Hardhat Network:**
```bash
npx hardhat node               # starts local chain
```

Both support mainnet forking — running a local chain that mirrors mainnet state. Essential for testing against real DeFi protocols.

## Deployment

**Foundry script:**
```solidity
// script/Deploy.s.sol
import "forge-std/Script.sol";
import "../src/Token.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerKey);
        new Token(1_000_000e18);
        vm.stopBroadcast();
    }
}
```

```bash
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --verify
```

**Hardhat Ignition (declarative):**
```typescript
// ignition/modules/Token.ts
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Token", (m) => {
    const token = m.contract("Token", [1_000_000n * 10n ** 18n]);
    return { token };
});
```

```bash
npx hardhat ignition deploy ignition/modules/Token.ts --network sepolia
```

## Testing Strategy

| Level | Tool | What It Tests |
|---|---|---|
| Unit tests | Foundry `forge test` / Hardhat | Individual functions, edge cases |
| Fuzz tests | Foundry (built-in) / Echidna | Random inputs, property-based invariants |
| Integration tests | Fork mode (anvil/hardhat) | Interaction with real mainnet contracts |
| Invariant tests | Foundry invariant mode | System-wide properties across random call sequences |
| Formal verification | Halmos, Certora | Mathematical proof of correctness |
| Gas snapshots | `forge snapshot` | Regression testing for gas usage |

**Minimum viable test strategy:** Unit tests + fuzz tests + fork-mode integration tests. Add formal verification before mainnet launch for any contract holding significant value.

## Verification and Etherscan

After deploying, verify your contract source on Etherscan so users can read the code:

```bash
# Foundry
forge verify-contract <address> src/Token.sol:Token --etherscan-api-key $KEY

# Hardhat
npx hardhat verify --network mainnet <address> "constructor arg 1" "arg 2"
```

Verified contracts show a green checkmark on Etherscan and let users interact via the "Read/Write Contract" tabs.

---
*Previous: [06-token-standards.md](06-token-standards.md) | Next: [08-web3-frontend.md](08-web3-frontend.md)*
