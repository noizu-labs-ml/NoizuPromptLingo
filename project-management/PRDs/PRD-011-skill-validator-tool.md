# PRD-011: Skill Validator Tool

**Automated validation and evaluation framework for skills.**

---

## Problem Statement

Creating skills requires following [SKILL-GUIDELINE.md](../../docs/reference/SKILL-GUIDELINE.md), which has many requirements:
- Directory structure with 4 folders (SKILL.md, EVAL/, FINE-TUNE/, MULTI-SHOT/)
- Specific file formats (rubric.md, training_data.parquet, index.yaml)
- Content standards (100-150 fine-tuning examples, 3 multi-shot examples)
- Quality metrics (examples must score 3+/4.0)

**Without validation:**
- Manual checking is error-prone and time-consuming
- Quality issues discovered late in development
- Inconsistent skill structure across the system
- Difficult to onboard new skill creators

**Solution:** Automated validator tool that checks structure and evaluates quality using Arize Phoenix.

---

## Solution Overview

Two-part validator:

### Part 1: Structure Validator
Checks that skill directory follows SKILL-GUIDELINE.md:
- All required folders present (EVAL, FINE-TUNE, MULTI-SHOT)
- All required files exist with correct format
- File naming conventions correct
- YAML/Parquet syntax valid
- Content requirements met (line counts, example counts, etc.)

**Output:** Pass/Fail report with specific issues

### Part 2: Quality Evaluator (Arize Phoenix)
Evaluates skill quality using Arize Phoenix:
- Loads EVAL rubric.md
- Runs MULTI-SHOT examples through evaluation
- Compares fine-tuning dataset quality against rubric
- Generates evaluation report with scores
- Interactive Jupyter/LiveBook notebook for exploration

**Output:** Arize Phoenix evaluation dashboard + Jupyter notebook

---

## Requirements

### Part 1: Structure Validator

#### Input
- Path to skill directory: `skills/[skill-name]/`

#### Checks Performed

**Directory Structure**
- [ ] `SKILL.md` exists
- [ ] `EVAL/` folder exists with: rubric.md, examples.md, checklist.md
- [ ] `FINE-TUNE/` folder exists with: README.md, training_data.parquet
- [ ] `MULTI-SHOT/` folder exists with: index.yaml, 3+ example files
- [ ] At least 2 prompt files exist: `[name].prompt.md`

**SKILL.md Validation**
- [ ] File is 1,500+ lines (minimum comprehensive)
- [ ] Contains all required sections:
  - Header (title + tagline)
  - Overview
  - When to Use
  - Core Concepts (if applicable)
  - Process/Methodology
  - Common Mistakes
  - Next Steps
  - Related Skills
  - Evaluation & Completion section linking to EVAL/
  - Version History
- [ ] No broken internal links
- [ ] Markdown renders without errors

**Prompt File Validation**
- [ ] Each `.prompt.md` is 300+ lines
- [ ] Contains PROMPT: header
- [ ] Has "What to Provide" section
- [ ] Has "Expected Output" section
- [ ] Has "Tips for Best Results" section
- [ ] Has "Related Prompts" section
- [ ] Markdown renders without errors

**EVAL/ Folder Validation**
- [ ] `rubric.md` contains:
  - Title and description
  - 3-5 dimensions (not fewer, not more)
  - Each dimension has 0-4 scale with criteria
  - Weights sum to 100%
  - Pass threshold defined (e.g., 2.5+/4.0)
  - Examples showing each score level
- [ ] `examples.md` contains:
  - 2-3 output type examples
  - Each with Good (4/4), Fair (2/4), Poor (0/4) samples
  - Explanation of why each level
  - How to improve from fair to good
- [ ] `checklist.md` contains:
  - 3-4 categories
  - 10-15 verifiable items
  - Binary yes/no items (not subjective)

**FINE-TUNE/ Folder Validation**
- [ ] `README.md` contains:
  - Title and description
  - 2-3 fine-tuning goals with specific improvements
  - Dataset overview (size, format, distribution)
  - Data quality notes and sources
  - Recommended approaches (Full FT, LoRA, ICL)
  - Hyperparameter suggestions
  - Success metrics and target improvements
  - Dataset versioning section
  - File is 1,000+ lines
- [ ] `training_data.parquet` exists and:
  - Is valid parquet file (readable by pandas)
  - Has 'prompt' column (string)
  - Has 'response' column (string)
  - Has 'metadata' column (JSON string)
  - Contains 100-150 rows (minimum viable dataset)
  - All rows have non-empty prompt and response
  - Average response length 250+ tokens

**MULTI-SHOT/ Folder Validation**
- [ ] `index.yaml` exists and:
  - Is valid YAML
  - Has 'examples' list with 3+ entries
  - Each example has: id, title, description, complexity, time_estimate, file, prerequisites
  - Complexity values are: beginner, intermediate, or advanced
  - All referenced files exist
- [ ] Example files exist:
  - Beginner: 400+ lines
  - Intermediate: 600+ lines
  - Advanced: 800+ lines
- [ ] Example files contain:
  - Title and complexity level
  - Overview section
  - 3+ steps showing progression
  - YAML chat format with: request, response, reasoning, next_steps
  - Key Takeaways section
  - Next Steps section

**File Naming**
- [ ] Prompt files: `[descriptive-name].prompt.md` (lowercase, hyphens)
- [ ] Skill directory: `[descriptive-name]` (lowercase, hyphens)
- [ ] Multi-shot files: `[complexity]-[descriptive-name].md`

#### Output Format

```json
{
  "skill": "market-intelligence",
  "path": "skills/market-intelligence",
  "status": "PASS" | "FAIL",
  "summary": "Skill structure is valid and complete",
  "checks": {
    "directory_structure": {
      "status": "PASS" | "FAIL",
      "items": [
        {"check": "SKILL.md exists", "status": "PASS"},
        {"check": "EVAL/ folder exists", "status": "PASS"},
        {"check": "FINE-TUNE/ folder exists", "status": "PASS"},
        {"check": "MULTI-SHOT/ folder exists", "status": "PASS"},
        ...
      ]
    },
    "skill_md": {
      "status": "PASS" | "FAIL",
      "line_count": 3200,
      "issues": ["Missing 'Related Skills' section"]
    },
    "prompts": {
      "status": "PASS" | "FAIL",
      "files": [
        {"file": "niche-discovery.prompt.md", "status": "PASS", "line_count": 850},
        {"file": "audience-profiling.prompt.md", "status": "PASS", "line_count": 720}
      ]
    },
    "eval_folder": {
      "status": "PASS" | "FAIL",
      "rubric": {
        "status": "PASS",
        "dimensions": 4,
        "weights_total": 100
      },
      "issues": []
    },
    "fine_tune_folder": {
      "status": "PASS" | "FAIL",
      "dataset": {
        "row_count": 125,
        "avg_response_tokens": 340,
        "status": "PASS"
      },
      "issues": []
    },
    "multi_shot_folder": {
      "status": "PASS" | "FAIL",
      "examples": [
        {"id": "beginner-niche-validation", "status": "PASS", "line_count": 620},
        {"id": "intermediate-audience-profiling", "status": "PASS", "line_count": 720},
        {"id": "advanced-competitive-analysis", "status": "PASS", "line_count": 850}
      ],
      "issues": []
    }
  },
  "timestamp": "2026-02-02T10:30:00Z"
}
```

#### CLI Interface

```bash
# Validate single skill
python tools/skill_validator.py skills/market-intelligence/

# Validate all skills
python tools/skill_validator.py skills/ --all

# Generate HTML report
python tools/skill_validator.py skills/market-intelligence/ --report html

# JSON output
python tools/skill_validator.py skills/market-intelligence/ --output json

# Verbose output
python tools/skill_validator.py skills/market-intelligence/ -v
```

---

### Part 2: Quality Evaluator (Arize Phoenix)

#### Approach

1. **Load EVAL Rubric**
   - Parse `EVAL/rubric.md`
   - Extract scoring dimensions and criteria
   - Convert to Arize Phoenix metrics

2. **Evaluate Fine-Tuning Dataset**
   - Load `training_data.parquet`
   - Sample 10-20 examples
   - Check if each example scores 3+/4.0 on EVAL rubric
   - Run Phoenix evaluation on sample

3. **Evaluate Multi-Shot Examples**
   - Load MULTI-SHOT examples
   - Extract actual outputs from YAML chat
   - Evaluate against EVAL rubric
   - Generate scores and detailed feedback

4. **Generate Report**
   - Arize Phoenix dashboard with metrics
   - Jupyter/LiveBook notebook for exploration
   - Comparison of expected vs actual quality

#### Arize Phoenix Integration

**Metrics to Track:**
- Dataset quality score (% examples scoring 3+/4.0)
- Multi-shot example quality (scores for each)
- Dimension-by-dimension breakdown
- Trending (if skill is updated, track improvements)

**Dashboard Elements:**
- Overall skill quality score
- Distribution of fine-tuning example scores
- Multi-shot example evaluations
- Dimension heatmap (which dimensions strong/weak)
- Benchmark comparisons (vs other skills)

#### Jupyter/LiveBook Notebook

**Cells:**

```python
# 1. Load skill and EVAL rules
skill_path = "skills/market-intelligence/"
rubric = load_rubric(f"{skill_path}/EVAL/rubric.md")
training_data = load_parquet(f"{skill_path}/FINE-TUNE/training_data.parquet")
multi_shots = load_multi_shots(f"{skill_path}/MULTI-SHOT/")

# 2. Visualize EVAL rubric
display_rubric_breakdown(rubric)  # Shows dimensions and weights

# 3. Score training dataset
scores = evaluate_dataset(training_data, rubric)
visualize_score_distribution(scores)  # Histogram of scores

# 4. Identify low-quality examples
low_quality = scores[scores['total_score'] < 3.0]
display_examples_by_score(training_data, scores)

# 5. Evaluate multi-shot examples
multi_shot_scores = evaluate_multi_shots(multi_shots, rubric)
show_multi_shot_feedback(multi_shot_scores)

# 6. Dimension analysis
dimension_heatmap(scores, rubric)  # Which dimensions are weak?
recommendations = suggest_improvements(scores, rubric)

# 7. Compare to other skills
skill_benchmark = compare_to_other_skills()
show_relative_quality(skill_benchmark)
```

**Output:**
- Interactive visualizations
- Sortable tables of examples with scores
- Dimension breakdown charts
- Recommendations for improvement
- Exportable evaluation report

#### Deliverables

**Structure Validator:**
- `tools/skill_validator.py` - Main CLI tool
- `tools/validators/` - Modular validator components
  - `structure_validator.py`
  - `skill_md_validator.py`
  - `eval_validator.py`
  - `fine_tune_validator.py`
  - `multi_shot_validator.py`

**Quality Evaluator:**
- `tools/skill_evaluator.py` - Arize Phoenix integration
- `notebooks/skill_evaluation_template.ipynb` - Template notebook
- `tools/arize_integration.py` - Phoenix client setup

---

## Success Criteria

### Part 1: Structure Validator
- ✅ Validates all directory structure requirements
- ✅ Checks all file format requirements (YAML, Parquet, Markdown)
- ✅ Clear error messages for failures
- ✅ <1 second validation time per skill
- ✅ JSON + HTML report output
- ✅ CLI interface is intuitive

### Part 2: Quality Evaluator
- ✅ Loads EVAL rubrics correctly
- ✅ Runs Arize Phoenix evaluations
- ✅ Generates Jupyter notebook with 7+ analysis cells
- ✅ Shows dimension-by-dimension breakdown
- ✅ Identifies low-quality training examples
- ✅ Provides actionable improvement recommendations
- ✅ Notebook is interactive and explorable

---

## Timeline

**Part 1 (Structure Validator):** 8-12 hours
- Core validator logic
- Format validation (YAML, Parquet, Markdown)
- CLI interface
- Report generation

**Part 2 (Quality Evaluator):** 8-10 hours
- Arize Phoenix integration
- EVAL rubric parser
- Evaluation logic
- Jupyter notebook templates
- Visualization components

**Total:** 16-22 hours

---

## Future Enhancements

- [ ] Pre-commit hook that validates skills before commit
- [ ] GitHub Actions workflow to validate on PR
- [ ] Skill quality dashboard (view all skills' evaluation scores)
- [ ] Automated suggestions to fix structure issues
- [ ] Track quality metrics over time (trending)
- [ ] Compare skills to identify best practices

---

*PRD for Skill Validator Tool - Two-Part Implementation*
