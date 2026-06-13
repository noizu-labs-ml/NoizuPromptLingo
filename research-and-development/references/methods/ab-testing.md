# A/B Testing

Comparative experiment design for measuring the impact of a single change.

## When to Use

- Comparing two (or more) variants of a design, feature, or approach
- You can randomly assign subjects to groups
- You have enough traffic/volume for statistical significance
- The outcome is measurable within a reasonable timeframe

## Core Concepts

| Term | Definition |
|------|-----------|
| **Control** | The unchanged original (A) |
| **Treatment** | The variant being tested (B) |
| **Conversion** | The desired outcome (signup, purchase, click) |
| **Lift** | Relative improvement: (B - A) / A |
| **Statistical significance** | Confidence that the difference isn't random noise |
| **Power** | Probability of detecting a real effect if one exists |

## Design Checklist

1. **Define one primary metric** — The single number that decides the test
2. **State the minimum detectable effect (MDE)** — How small a difference matters?
3. **Calculate sample size** — Based on baseline rate, MDE, and desired power
4. **Define assignment method** — Random, stratified, or deterministic
5. **Set duration** — Long enough for full business cycles (include weekends)
6. **Pre-register analysis** — What test, what threshold, when to look

## Sample Size Rules of Thumb

For a standard two-proportion z-test at 80% power, α = 0.05:

| Baseline Rate | MDE (relative) | Sample per Group |
|--------------|----------------|-----------------|
| 5% | 10% | ~31,000 |
| 5% | 20% | ~8,000 |
| 10% | 10% | ~14,800 |
| 10% | 20% | ~3,800 |
| 20% | 10% | ~6,800 |
| 20% | 20% | ~1,700 |

**Lower baseline rates need bigger samples.** A 1% → 1.1% change needs ~150,000 per group.

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Peeking at results early | Inflates false positive rate | Pre-commit to run duration |
| Ending when significant | Same as peeking | Fixed sample or sequential testing |
| Too many variants | Reduces power per comparison | Test 2-3 max; adjust for multiple comparisons |
| Unequal groups | Wastes statistical power | Use 50/50 split (or optimize with unequal allocation only when justified) |
| Short duration | Misses weekly patterns | Run at least 1-2 full business cycles |
| Changing the test mid-run | Invalidates results | If you must change, restart from zero |

## Analysis Template

```markdown
### A/B Test Results: [Test Name]

**Duration:** [start] to [end]
**Groups:** Control (n = [X]) vs Treatment (n = [Y])

| Metric | Control | Treatment | Lift | p-value | Significant? |
|--------|---------|-----------|------|---------|-------------|
| [primary metric] | [value] | [value] | [%] | [p] | [yes/no] |
| [secondary metric] | [value] | [value] | [%] | [p] | [yes/no] |

**Effect size:** [Cohen's h or relative lift]
**Confidence interval:** [lower, upper] at 95%
**Conclusion:** [plain language interpretation]
```

## Multivariate Testing

When testing multiple changes simultaneously:

- Use factorial design (test all combinations)
- Requires much larger sample sizes (multiplied by number of combinations)
- Can detect interaction effects (A and B together are better than either alone)
- Only use when you have the traffic to support it
