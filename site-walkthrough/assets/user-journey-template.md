# Journey Log: {Goal Name}

| Field | Value |
|-------|-------|
| **Run ID** | `{run-id}` |
| **Date** | {YYYY-MM-DD} |
| **Goal** | `{goal-slug}` |
| **Site** | {domain} |
| **Persona** | {Name} — {Label} |
| **Lens** | {lens-type} |
| **Overall Verdict** | {verdict with icon} |

---

## Persona Constraints

- {constraint 1}
- {constraint 2}
- Watches for: {watch items}

---

## Flow Visualization

```mermaid
graph TD
    S1["Step 1: {action}<br/>{verdict icon}"] --> S2["Step 2: {action}<br/>{verdict icon}"]
    S2 --> S3["Step 3: {action}<br/>{verdict icon}"]

    style S1 fill:#d3f9d8,stroke:#2b8a3e
    %% Green = OK, Yellow = friction, Red = blocked
```

---

## Step-by-Step Observations

### Step 1: {Action} :arrow_right: {verdict icon} {verdict}

**What {persona name} sees:**

```mermaid
graph LR
    subgraph "{Step description}"
        ELEM1["{element}"]
        ELEM2["{element}"]
    end
```

![{description}](assets/step1-{slug}.png)

**Observation:** {what the persona experiences through their lens}

**Issues:**

| ID | Severity | Issue | Recommendation |
|----|----------|-------|----------------|
| ISS-{N} | {icon} {level} | {description} | {fix} |

---

<!-- Repeat for each step -->

---

## Severity Summary

```mermaid
pie title Issue Severity — {Persona Name}
    "Critical" : 0
    "High" : 0
    "Medium" : 0
```

| Severity | Count | Steps Affected |
|----------|-------|---------------|
| :red_circle: Critical | 0 | — |
| :red_circle: High | 0 | — |
| :yellow_circle: Medium | 0 | — |
| :green_circle: Low | 0 | — |

---

## Verdict

**Completion:** {can/cannot complete, with what difficulty}

**Top fix:** {single most impactful recommendation}
