# Audit Patterns & Security Checklist

A practical checklist for reviewing smart contract security, whether you're self-auditing or preparing for a professional audit.

## Pre-Audit Checklist

Before any external audit, run through these yourself:

### Access Control
- [ ] Every state-changing function has appropriate access control
- [ ] Admin/owner privileges are documented and minimized
- [ ] `initialize()` functions can only be called once (for proxies)
- [ ] No `tx.origin` checks (use `msg.sender`)
- [ ] Ownership transfer is two-step (nominate + accept) to prevent accidental lockout
- [ ] Timelock on critical admin actions (parameter changes, upgrades)

### Reentrancy
- [ ] All external calls follow Checks-Effects-Interactions pattern
- [ ] `ReentrancyGuard` on functions that transfer ETH or tokens
- [ ] Cross-function reentrancy paths reviewed (different functions, same state)
- [ ] Read-only reentrancy considered (view functions called during external calls)

### Arithmetic
- [ ] No `unchecked` blocks without proof of safety
- [ ] Division before multiplication avoided (precision loss)
- [ ] Decimal handling consistent (especially cross-token: 6 vs 18 decimals)
- [ ] No phantom overflow in intermediate calculations

### Token Handling
- [ ] Using `SafeERC20` for all token transfers
- [ ] Handles fee-on-transfer tokens if applicable
- [ ] Handles rebasing tokens if applicable
- [ ] Approval amounts are exact (not `type(uint256).max`) where possible
- [ ] No assumption that `transfer()` reverts on failure (some return false)

### Oracle Usage
- [ ] Price feeds have staleness checks
- [ ] Multiple oracle sources or TWAP (not spot prices)
- [ ] Circuit breakers for extreme price movements
- [ ] Graceful degradation if oracle is unavailable

### External Calls
- [ ] Return values of low-level `.call()` are checked
- [ ] No delegatecall to untrusted addresses
- [ ] Gas limits considered for external calls
- [ ] Callback patterns are safe (no unexpected state changes)

### Gas & DoS
- [ ] No unbounded loops over dynamic arrays
- [ ] No reliance on specific gas costs (they change with EVM upgrades)
- [ ] Pull-over-push for ETH/token distributions
- [ ] Array lengths bounded by a reasonable maximum

### Upgrade Safety (if using proxies)
- [ ] Storage layout is consistent between versions
- [ ] No constructor logic (use `initialize()`)
- [ ] Implementation contract is initialized (can't be taken over)
- [ ] `_disableInitializers()` called in implementation constructor
- [ ] Upgrade path is tested end-to-end

### General
- [ ] All public/external functions have NatSpec documentation
- [ ] Events emitted for all state changes
- [ ] No hardcoded addresses (use constructor params or constants)
- [ ] Contract size under 24KB limit (EIP-170)
- [ ] Compiler warnings resolved (no unused variables, shadowing)
- [ ] Test coverage > 90% for critical paths

## Common Audit Findings by Severity

### Critical (Immediate fund loss risk)
- Reentrancy allowing fund drain
- Missing access control on mint/burn/withdraw
- Flash loan oracle manipulation
- Uninitialized proxy implementation

### High (Potential fund loss under specific conditions)
- Integer overflow in `unchecked` blocks
- Incorrect share/token accounting
- Missing slippage protection
- Stale oracle prices

### Medium (Functionality issues, no direct fund loss)
- Missing event emissions
- Centralization risks (single owner key)
- Front-running vulnerability on price-sensitive operations
- Inconsistent decimal handling

### Low / Informational
- Gas optimizations
- Code style / naming conventions
- Missing NatSpec
- Unused imports or variables

## The "Think Like an Attacker" Framework

For each function, ask:
1. **Who can call this?** (access control)
2. **What happens if I call it with extreme values?** (0, max uint256, empty arrays)
3. **What happens if I call it multiple times rapidly?** (reentrancy)
4. **What happens if I call it in the same transaction as something else?** (flash loans, MEV)
5. **What state does this read, and could that state be stale?** (oracle manipulation, reentrancy)
6. **What external contracts does this interact with, and could they be malicious?** (composability)
7. **What happens if this fails partway through?** (partial execution, gas exhaustion)

## Post-Launch Monitoring

Security doesn't end at deployment:

- **Real-time monitoring** — Forta bots, OZ Defender Sentinels for unusual patterns
- **Bug bounty** — Immunefi (dominant platform). Set bounty proportional to TVL.
- **Incident response plan** — Who does what if an exploit is detected? Emergency pause? Multisig action?
- **Upgrade governance** — Timelock + multisig for any parameter changes or contract upgrades

---
*Previous: [11-security-tools.md](11-security-tools.md) | Next: [13-layer2-scaling.md](13-layer2-scaling.md)*
