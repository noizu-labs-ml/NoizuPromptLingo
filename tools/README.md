# Skill Validation & Evaluation Tools

Two-part validation system for skills following [SKILL-GUIDELINE.md](../docs/reference/SKILL-GUIDELINE.md).

---

## Part 1: Structure Validator

Checks that skill directories follow SKILL-GUIDELINE.md structure requirements.

### Usage

```bash
# Validate single skill
python tools/skill_validator.py skills/market-intelligence/

# Validate all skills
python tools/skill_validator.py skills/ --all

# Generate HTML report
python tools/skill_validator.py skills/market-intelligence/ --report html

# JSON output
python tools/skill_validator.py skills/market-intelligence/ --report json -o report.json

# Verbose output
python tools/skill_validator.py skills/market-intelligence/ -v
```

### What It Checks

**Directory Structure**
- ✅ Required files: SKILL.md
- ✅ Required folders: EVAL/, FINE-TUNE/, MULTI-SHOT/
- ✅ Prompt files: 2+ `.prompt.md` files

**SKILL.md**
- ✅ Minimum 1,500 lines
- ✅ All required sections present
- ✅ Markdown syntax valid
- ✅ Links to EVAL folder

**Prompt Files**
- ✅ 300+ lines each
- ✅ Required sections (What to Provide, Expected Output, Tips, Related Prompts)
- ✅ Markdown valid

**EVAL/ Folder**
- ✅ rubric.md: 3-5 dimensions, 0-4 scale, weights sum to 100%
- ✅ examples.md: good/fair/poor examples for each output type
- ✅ checklist.md: 10-15 verifiable items

**FINE-TUNE/ Folder**
- ✅ README.md: 1,000+ lines with strategy and hyperparameters
- ✅ training_data.parquet: 100-150 examples in OASST format
- ✅ All examples have valid prompt + response
- ✅ Average response 250+ tokens

**MULTI-SHOT/ Folder**
- ✅ index.yaml: valid YAML with 3+ examples indexed
- ✅ Example files: beginner (400+ lines), intermediate (600+), advanced (800+)
- ✅ YAML chat format with request/response pairs
- ✅ Required sections (Overview, Key Takeaways, Next Steps)

### Output Format

**Text Report** (default)
```
==============================================================
VALIDATION REPORT: market-intelligence
==============================================================

✅ Status: PASS
📍 Path: skills/market-intelligence
⏰ Timestamp: 2026-02-02T10:30:00Z

✅ Skill structure is valid and complete

✅ Directory Structure
  ✅ SKILL.md exists
  ✅ EVAL/ folder exists
  ...
```

**JSON Report**
```json
{
  "skill": "market-intelligence",
  "path": "skills/market-intelligence",
  "status": "PASS",
  "timestamp": "2026-02-02T10:30:00Z",
  "checks": {
    "directory_structure": { "status": "PASS", "items": [...] },
    "skill_md": { "status": "PASS", "line_count": 3200, "items": [...] },
    ...
  }
}
```

**HTML Report**
Interactive HTML page with check results and issue lists.

---

## Part 2: Quality Evaluator

Evaluates skill quality using Arize Phoenix metrics and generates Jupyter notebooks.

### Usage

```bash
# Evaluate single skill
python tools/skill_evaluator.py skills/market-intelligence/

# Generate Jupyter notebook for exploration
python tools/skill_evaluator.py skills/market-intelligence/ --notebook

# Custom notebook output
python tools/skill_evaluator.py skills/market-intelligence/ --notebook -o notebooks/my_eval.ipynb

# Export Phoenix metrics
python tools/skill_evaluator.py skills/market-intelligence/ --export phoenix_metrics.json
```

### What It Does

**Loads EVAL Rubric**
- Parses `EVAL/rubric.md`
- Extracts dimensions and scoring criteria
- Converts to Phoenix metrics format

**Evaluates Fine-Tuning Dataset**
- Loads `training_data.parquet` sample
- Scores examples against EVAL rubric
- Calculates quality statistics
- Identifies low-quality examples

**Evaluates Multi-Shot Examples**
- Extracts outputs from YAML chat threads
- Scores each example against rubric
- Provides dimension-by-dimension feedback
- Identifies improvement opportunities

**Generates Jupyter Notebook**
Creates interactive notebook with:
- 7+ analysis cells
- Rubric visualization
- Dataset quality analysis
- Example evaluation breakdown
- Dimension heatmap
- Quality improvement recommendations
- Interactive tables and charts

### Jupyter Notebook Cells

1. **Setup** - Import libraries and configure visualization
2. **Load Skill and Rubric** - Load EVAL rules and dataset
3. **Visualize Rubric** - Show dimensions and scoring criteria
4. **Dataset Quality** - Statistical analysis of training data
5. **Example Evaluation** - Score multi-shot examples
6. **Dimension Breakdown** - Which dimensions strong/weak
7. **Recommendations** - Actionable improvements

### Example Output

```
Skill Evaluation: market-intelligence
======================================

📊 Loading EVAL rubric...
   Found 4 dimensions: niche_validation (25%), research_depth (25%),
                       audience_clarity (25%), actionability (25%)

🔍 Evaluating fine-tuning dataset...
   Sample size: 20/125 examples
   Mean quality score: 3.2/4.0 ✅
   Passing rate: 95% (19/20 score 3+/4.0)

🎯 Evaluating multi-shot examples...
   beginner-niche-validation.md: 3.5/4.0 ✅
   intermediate-audience-profiling.md: 3.2/4.0 ✅
   advanced-competitive-analysis.md: 3.6/4.0 ✅

📈 Dashboard metrics generated
✅ Notebook generated: notebooks/market-intelligence_evaluation.ipynb
```

---

## Integration with Arize Phoenix

The quality evaluator exports metrics in Phoenix-compatible format:

```json
{
  "skill": "market-intelligence",
  "overall_score": 3.4,
  "dimensions": {
    "niche_validation": {
      "score": 3.5,
      "distribution": {"low": 2, "medium": 8, "high": 10}
    },
    ...
  },
  "metrics_summary": { ... }
}
```

This data can be imported into Arize Phoenix for:
- Tracking skill quality over time
- Comparing skills to identify best practices
- Setting quality baselines and targets
- Visualizing trends and regressions

---

## Modular Validators (Part 1)

Located in `tools/validators/`:

- **structure_validator.py** - Directory structure checks
- **skill_md_validator.py** - SKILL.md content validation
- **prompts_validator.py** - Prompt file validation
- **eval_validator.py** - EVAL folder validation
- **fine_tune_validator.py** - FINE-TUNE folder validation
- **multi_shot_validator.py** - MULTI-SHOT folder validation

Each validator is independent and can be imported/used separately.

---

## Arize Phoenix Integration (Part 2)

Located in `tools/arize_integration.py`:

- **PhoenixEvaluator** - Wrapper for Phoenix evaluations
- **RubricParser** - Parse SKILL-GUIDELINE compliant rubrics
- Metric aggregation and reporting
- Phoenix-compatible metric export

---

## Requirements

**Part 1 (Structure Validator)**
- Python 3.8+
- `pyyaml` (for index.yaml validation)

**Part 2 (Quality Evaluator)**
- Python 3.8+
- `pandas` (for parquet dataset handling)
- `pyyaml` (for rubric parsing)

**Optional (for Arize Phoenix integration)**
- `arize` Python SDK (when available)
- Jupyter/JupyterLab (to run generated notebooks)

---

## Quick Start

1. **Validate skill structure**
   ```bash
   python tools/skill_validator.py skills/your-skill/ --report text
   ```

2. **Evaluate quality**
   ```bash
   python tools/skill_evaluator.py skills/your-skill/ --notebook
   ```

3. **Open generated notebook**
   ```bash
   jupyter notebook notebooks/your-skill_evaluation.ipynb
   ```

4. **Export for Phoenix**
   ```bash
   python tools/skill_evaluator.py skills/your-skill/ --export metrics.json
   ```

---

## Development Notes

- Validators use modular design for easy extension
- Quality evaluator uses placeholder scoring (ready for real LLM evaluation)
- Jupyter notebooks are dynamically generated with templated cells
- All tools output JSON for programmatic use
- HTML reports can be embedded in dashboards

---

## Future Enhancements

- [ ] Pre-commit hooks for automatic validation
- [ ] GitHub Actions workflow integration
- [ ] Skill quality dashboard (visualize all skills)
- [ ] Automated fixing of common structure issues
- [ ] Real LLM-based evaluation (Claude API integration)
- [ ] Skill quality trending over time
- [ ] Benchmark comparisons across similar skills
- [ ] Interactive Phoenix dashboard generation

---

*Tools for validating skills against SKILL-GUIDELINE.md*
