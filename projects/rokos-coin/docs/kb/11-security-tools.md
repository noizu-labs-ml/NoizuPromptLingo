# Security Tools & Formal Verification

## The Security Tool Stack

Think of security tooling as layers, each catching different classes of bugs:

```
Manual code review         ← Catches logic errors, design flaws (most important)
    ↓
Static analysis (Slither)  ← Catches known vulnerability patterns automatically
    ↓
Fuzz testing (Echidna/Foundry) ← Finds edge cases via random inputs
    ↓
Symbolic execution (Halmos/Mythril) ← Proves properties or finds counterexamples
    ↓
Formal verification (Certora) ← Mathematical proof of correctness
```

Each layer is more rigorous but also more expensive in time and expertise.

## Static Analysis: Slither

**What it does:** Reads your Solidity source code and checks for ~80+ known vulnerability patterns without executing anything.

**Maintained by:** Trail of Bits (Crytic suite)

```bash
# Install
pip3 install slither-analyzer

# Run
slither .                        # analyze all contracts
slither . --print human-summary  # high-level overview
slither . --detect reentrancy-eth,uninitialized-state  # specific detectors
```

**What it catches:**
- Reentrancy vulnerabilities
- Uninitialized state variables
- Unused return values
- Dangerous delegatecall patterns
- Access control issues
- Naming convention violations

**What it misses:**
- Business logic errors
- Complex cross-contract interactions
- Economic design flaws

**Verdict:** Run on every project, every commit. It's fast, free, and catches low-hanging fruit. High false-positive rate — learn to triage.

## Aderyn (Newer Alternative)

Rust-based static analyzer from Cyfrin. Faster than Slither, growing detector set. Worth watching but Slither remains more comprehensive.

```bash
# Install
curl -L https://raw.githubusercontent.com/Cyfrin/aderyn/dev/scripts/install.sh | bash

# Run
aderyn .
```

## Fuzz Testing: Foundry + Echidna

### Foundry Fuzzing (Built-in)

Any test function with parameters gets fuzzed automatically:

```solidity
function testFuzz_withdraw(uint256 amount) public {
    amount = bound(amount, 1, address(this).balance);
    
    uint256 balanceBefore = token.balanceOf(address(this));
    token.withdraw(amount);
    
    assertEq(token.balanceOf(address(this)), balanceBefore - amount);
}
```

Foundry generates hundreds/thousands of random inputs and checks your assertions hold for all of them.

### Foundry Invariant Testing

Tests properties that must hold across random sequences of function calls:

```solidity
// This must always be true, no matter what sequence of calls happens
function invariant_totalSupplyMatchesBalances() public {
    uint256 sum = 0;
    for (uint i = 0; i < holders.length; i++) {
        sum += token.balanceOf(holders[i]);
    }
    assertEq(token.totalSupply(), sum);
}
```

Foundry will randomly call contract functions in random order with random args, checking the invariant after each call. This finds bugs that single-function tests miss.

### Echidna (Trail of Bits)

A dedicated fuzzer with corpus-guided exploration (smarter than random). Better for deep stateful fuzzing campaigns.

```solidity
contract TokenEchidnaTest is Token {
    constructor() Token(1_000_000e18) {}
    
    function echidna_total_supply_constant() public view returns (bool) {
        return totalSupply() == 1_000_000e18;
    }
}
```

```bash
echidna . --contract TokenEchidnaTest --config echidna.yaml
```

**When to use Echidna over Foundry fuzzing:** Complex stateful properties, long fuzzing campaigns (hours/days), when you need corpus persistence across runs.

## Symbolic Execution: Halmos & Mythril

### Halmos (Foundry-native)

Runs your existing Foundry property tests with symbolic inputs instead of random inputs. Instead of testing "does this hold for 10,000 random values?" it asks "does this hold for ALL possible values?"

```bash
pip3 install halmos
halmos --function testFuzz_withdraw
```

**Bounded verification:** Halmos explores all paths up to a configurable depth. Not a complete proof (can't handle infinite loops) but catches more than fuzzing.

**Best for:** Foundry teams who want to upgrade their fuzz tests to symbolic tests with zero code changes.

### Mythril

Symbolic execution at the EVM bytecode level. Doesn't need source code — works on deployed contracts.

```bash
pip3 install mythril
myth analyze contracts/Token.sol
```

**What it finds:** Integer overflow, reentrancy, unchecked sends, delegatecall injection, state variable manipulation.

**Trade-off:** Slower than Slither, higher false-positive rate, but finds deeper bugs.

## Formal Verification: Certora

The gold standard. Writes mathematical specifications and proves they hold for all possible inputs and states.

**How it works:**
1. Write specs in CVL (Certora Verification Language):
```
rule transferDoesNotChangeOtherBalances(address sender, address recipient, uint256 amount) {
    env e;
    address other;
    require other != sender && other != recipient;
    
    uint256 balanceBefore = balanceOf(other);
    transfer(e, recipient, amount);
    uint256 balanceAfter = balanceOf(other);
    
    assert balanceBefore == balanceAfter;
}
```

2. Submit to Certora's cloud prover
3. Get a proof or a counterexample (the exact input sequence that breaks the property)

**Used by:** Aave, Compound, MakerDAO, OpenZeppelin — protocols with billions in TVL.

**Cost:** Commercial license required for full features. Free tier available for open-source projects.

## SMTChecker (Built into Solidity)

Free formal verification built into the Solidity compiler itself.

```solidity
/// @custom:smtchecker abstract-function-nondet
contract Token {
    mapping(address => uint256) balances;
    
    function transfer(address to, uint256 amount) external {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;
        // SMTChecker can prove this assert always holds
        assert(balances[msg.sender] + balances[to] >= amount);
    }
}
```

```bash
solc --model-checker-engine chc --model-checker-targets assert Token.sol
```

**Verdict:** Free first pass. Catches simple invariant violations. Limited in scope compared to Certora but zero cost.

## Recommended Security Pipeline

| Stage | Tool | When | Cost |
|---|---|---|---|
| **Every commit** | Slither | CI/CD pipeline | Free |
| **Every test run** | Foundry fuzz tests | Development | Free |
| **Weekly** | Foundry invariant tests (long runs) | Dedicated CI job | Free |
| **Pre-audit** | Halmos symbolic tests | Before external audit | Free |
| **Pre-mainnet** | Certora formal verification | For TVL > $10M | $$$  |
| **Post-launch** | Bug bounty (Immunefi) | Ongoing | Bounty payouts |

## Audit Process

For any contract handling real money:

1. **Internal review** — Team members review each other's code
2. **Automated tools** — Slither + fuzzing + Halmos (all the above)
3. **External audit** — Hire a professional audit firm
   - **Top firms (2026):** Trail of Bits, OpenZeppelin, Spearbit, Consensys Diligence, Cyfrin
   - **Cost:** $5K-$500K+ depending on codebase size and complexity
   - **Timeline:** 2-8 weeks
4. **Bug bounty** — Ongoing post-launch via Immunefi or HackerOne
5. **Monitoring** — Real-time alerts for unusual contract activity (Forta, OZ Defender)

---
*Previous: [10-security-pitfalls.md](10-security-pitfalls.md) | Next: [12-audit-patterns.md](12-audit-patterns.md)*
