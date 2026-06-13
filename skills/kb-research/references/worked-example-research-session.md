# KB Research — Worked Example: Machine Learning Fundamentals

> End-to-end walkthrough of a research session demonstrating the full trl-kb-research workflow: topic parsing, query generation, parallel dispatch, result collection, deduplication, quality evaluation, and final annotated bibliography.

---

## 1. Topic Parsing

**User request**: "Find resources on machine learning fundamentals"

### Parsed Brief

```yaml
topic: Machine Learning — Fundamentals
subtopics:
  - Supervised learning (regression, classification)
  - Unsupervised learning (clustering, dimensionality reduction)
  - Model evaluation and selection
  - Feature engineering
  - Neural network basics
level: Beginner to Intermediate
domain_category: Fast-moving (2-5 year recency threshold for applied content)
                  BUT fundamentals are more stable (5-10 years acceptable for theory)
constraints:
  - None specified — include all source types
  - Include both free and paid resources
  - English language
scope: Comprehensive survey
```

### Domain Recency Assessment

Machine learning is a split domain:
- **Fundamentals** (linear regression, SVMs, decision trees, bias-variance tradeoff) — stable for 10+ years
- **Deep learning practice** (specific architectures, frameworks, GPUs) — 2-3 year shelf life
- **LLM/GenAI frontier** — 6-12 months before outdated

For this request (fundamentals), resources from 2010-2025 are acceptable. Classic textbooks from 2006+ are fine if they cover core concepts well.

---

## 2. Query Generation

### Book Queries
1. `"best machine learning books for beginners"`
2. `"machine learning textbook recommended university"`
3. `"introduction to machine learning book ISBN"`
4. `"machine learning from scratch book"`

### Article Queries
1. `"machine learning comprehensive guide tutorial"`
2. `"machine learning explained beginners introduction"`
3. `"site:dev.to OR site:medium.com machine learning fundamentals guide"`

### Paper Queries
1. `"site:arxiv.org machine learning survey tutorial"`
2. `"machine learning introductory survey paper"`
3. `"statistical learning foundations review paper"`

### Open-Access Queries
1. `"machine learning free course MIT OCW Coursera"`
2. `"machine learning open textbook free PDF"`
3. `"machine learning lecture series YouTube Stanford"`

---

## 3. Parallel Dispatch

Three subagents dispatched simultaneously:

### Subagent 1: Book + Article Scout

```
Prompt: """
You are a book and article research scout. Find learning resources on:
Machine Learning Fundamentals (beginner to intermediate level).

BOOKS — Run these WebSearch queries:
1. "best machine learning books for beginners"
2. "machine learning textbook recommended university"
3. "introduction to machine learning book ISBN"

For each book, extract: Title, Author(s), ISBN-13, Publisher, Year, Synopsis,
Difficulty level. Use WebFetch on openlibrary.org to verify ISBNs.

ARTICLES — Run these WebSearch queries:
1. "machine learning comprehensive guide tutorial"
2. "machine learning explained beginners introduction"

For each article: Title, Author, URL, Platform, Date, Synopsis, Difficulty.
Only include substantive content (1500+ words or clear depth).

Mark unverified metadata with [Unverified]. Do not fabricate ISBNs.
"""
```

### Subagent 2: Paper Scout

```
Prompt: """
You are an academic paper research scout. Find papers on:
Machine Learning Fundamentals — prioritize survey papers and tutorials.

Run these WebSearch queries:
1. "site:arxiv.org machine learning survey tutorial"
2. "machine learning introductory survey paper"
3. "statistical learning foundations review paper"

For each paper: Title, Authors, Year, arXiv ID or DOI, URL, Abstract
(first 2-3 sentences), Citation count if visible.

Prioritize survey papers — they provide the best overview for learners.
Mark estimated citation counts with [Unverified].
"""
```

### Subagent 3: Open-Access Scout

```
Prompt: """
You are an open-access resource scout. Find free learning materials on:
Machine Learning Fundamentals (beginner to intermediate).

Run these WebSearch queries:
1. "machine learning free course MIT OCW Coursera"
2. "machine learning open textbook free PDF"
3. "machine learning lecture series YouTube Stanford"

For each resource: Title, URL, Platform, Format, License/Cost,
Difficulty, Estimated time commitment.

Verify URLs load using WebFetch where possible.
Only include genuinely free or free-to-audit resources.
"""
```

---

## 4. Raw Results (Simulated)

What each subagent returns (condensed for this example):

### From Subagent 1 (Books + Articles)

**Books found:**
1. "An Introduction to Statistical Learning" — James, Witten, Hastie, Tibshirani — ISBN: 978-1071614174 — Springer, 2nd Ed 2021
2. "Hands-On Machine Learning with Scikit-Learn, Keras, and TensorFlow" — Aurelien Geron — ISBN: 978-1098125974 — O'Reilly, 3rd Ed 2022
3. "Pattern Recognition and Machine Learning" — Christopher Bishop — ISBN: 978-0387310732 — Springer, 2006
4. "The Hundred-Page Machine Learning Book" — Andriy Burkov — ISBN: 978-1999579500 — Self-published, 2019
5. "Machine Learning: A Probabilistic Perspective" — Kevin Murphy — ISBN: 978-0262018029 — MIT Press, 2012
6. "Python Machine Learning" — Sebastian Raschka — 978-1789955750 — Packt, 3rd Ed 2019

**Articles found:**
1. "A Visual Introduction to Machine Learning" — R2D3 — r2d3.us — Interactive visualization
2. "Machine Learning is Fun!" — Adam Geitgey — Medium — 2014-2016 series
3. "Google's Machine Learning Crash Course" — Google — developers.google.com — Free interactive course

### From Subagent 2 (Papers)

1. "A Survey of Deep Learning Techniques" — Alzubaidi et al. — 2021 — DOI: 10.1186/s40537-021-00444-8
2. "A Few Useful Things to Know About Machine Learning" — Pedro Domingos — 2012 — CACM — DOI: 10.1145/2347736.2347755
3. "An Introduction to Machine Learning" — Amanpreet Singh et al. — arXiv:2405.00820 — 2024 [Unverified]
4. "A Tutorial on Support Vector Machines for Pattern Recognition" — Christopher Burges — 1998 — DOI: 10.1023/A:1009715923555

### From Subagent 3 (Open-Access)

1. Stanford CS229 — Andrew Ng — YouTube / Stanford Online — Full lecture series
2. fast.ai "Practical Deep Learning for Coders" — Jeremy Howard — course.fast.ai — Free
3. MIT 6.034 Artificial Intelligence — Patrick Winston — MIT OCW — Full course
4. Coursera "Machine Learning Specialization" — Andrew Ng — Audit free, certificate paid
5. "Mathematics for Machine Learning" — Deisenroth, Faisal, Ong — mml-book.github.io — Free PDF
6. Khan Academy Statistics & Probability — khanacademy.org — Prerequisite material

---

## 5. Deduplication and Quality Evaluation

### Deduplication Pass

No exact duplicates found across subagents (source types were different). However:
- Google ML Crash Course (from Article Scout) and Coursera ML Specialization (from Open-Access Scout) are different resources — both kept.
- "Mathematics for Machine Learning" (open-access) is a prerequisite resource, not a direct ML textbook — keep but categorize as prerequisite.

### Quality Scoring

| Resource | Author Cred (0.20) | Venue (0.15) | Depth (0.20) | Pedagogy (0.20) | Recency (0.10) | Access (0.10) | Recs (0.05) | **Total** |
|---|---|---|---|---|---|---|---|---|
| ISLR (James et al.) | 5 | 5 | 5 | 5 | 5 | 5 | 5 | **5.00** |
| Hands-On ML (Geron) | 4 | 5 | 5 | 5 | 5 | 3 | 5 | **4.55** |
| Stanford CS229 (Ng) | 5 | 5 | 5 | 4 | 4 | 5 | 5 | **4.75** |
| PRML (Bishop) | 5 | 5 | 5 | 3 | 3 | 3 | 5 | **4.15** |
| fast.ai (Howard) | 5 | 4 | 4 | 5 | 5 | 5 | 5 | **4.65** |
| ML Specialization (Ng) | 5 | 4 | 4 | 5 | 5 | 4 | 5 | **4.55** |
| Domingos paper | 5 | 5 | 3 | 3 | 3 | 5 | 4 | **3.80** |
| 100-Page ML (Burkov) | 3 | 2 | 3 | 4 | 4 | 4 | 4 | **3.35** |
| MML Book (Deisenroth) | 5 | 4 | 4 | 4 | 4 | 5 | 4 | **4.30** |
| Murphy (Probabilistic) | 5 | 5 | 5 | 3 | 3 | 2 | 4 | **4.00** |

---

## 6. Final Annotated Bibliography

### Books

#### An Introduction to Statistical Learning (ISLR)
- **Type**: Book
- **Author(s)**: Gareth James, Daniela Witten, Trevor Hastie, Robert Tibshirani
- **Year**: 2021 (2nd Edition)
- **ISBN**: 978-1071614174 [Verified]
- **Publisher**: Springer
- **Difficulty**: Beginner to Intermediate
- **Time Estimate**: ~40-60 hours
- **Synopsis**: The gold standard introduction to statistical/machine learning. Covers regression, classification, resampling, tree-based methods, SVMs, unsupervised learning, and deep learning (new in 2nd edition). Emphasizes intuition over mathematical rigor, with R and Python labs. Companion to the more advanced "Elements of Statistical Learning" by the same group.
- **Prerequisites**: Basic statistics (mean, variance, probability), some programming experience
- **Sourcing**: Free PDF from authors' website (statlearning.com) | Purchase ~$60 | Library (widely held)
- **Notes**: The free PDF makes this an unbeatable starting point. Labs available in both R and Python. The 2nd edition adds deep learning, survival analysis, and multiple testing chapters.
- **Confidence**: [Verified]
- **Score**: 5.00

#### Hands-On Machine Learning with Scikit-Learn, Keras, and TensorFlow
- **Type**: Book
- **Author(s)**: Aurelien Geron
- **Year**: 2022 (3rd Edition)
- **ISBN**: 978-1098125974 [Verified]
- **Publisher**: O'Reilly Media
- **Difficulty**: Beginner to Intermediate
- **Time Estimate**: ~50-70 hours
- **Synopsis**: Practical, project-driven introduction covering the full ML pipeline: data loading, training, evaluation, deployment. Part 1 covers classical ML with Scikit-Learn; Part 2 covers neural networks and deep learning with Keras/TensorFlow. Excellent for practitioners who learn by building.
- **Prerequisites**: Python programming, basic linear algebra helpful but not required
- **Sourcing**: Purchase ~$55 (O'Reilly, Amazon) | O'Reilly subscription | Library
- **Notes**: 3rd edition updated for TensorFlow 2.x and adds new chapters on preprocessing and deployment. GitHub repo with all code notebooks. Best practical complement to the more theoretical ISLR.
- **Confidence**: [Verified]
- **Score**: 4.55

#### Pattern Recognition and Machine Learning (PRML)
- **Type**: Book
- **Author(s)**: Christopher M. Bishop
- **Year**: 2006
- **ISBN**: 978-0387310732 [Verified]
- **Publisher**: Springer
- **Difficulty**: Intermediate to Advanced
- **Time Estimate**: ~80-120 hours
- **Synopsis**: Rigorous Bayesian treatment of machine learning covering probability distributions, linear models, neural networks, kernel methods, graphical models, and approximate inference. Beautifully written with excellent color figures. The mathematical depth makes it a long-term reference rather than a first book.
- **Prerequisites**: Linear algebra, multivariate calculus, probability theory
- **Sourcing**: Purchase ~$70 | Free PDF available from Microsoft Research (author's page) | Library (widely held)
- **Notes**: Despite being from 2006, the mathematical foundations it covers remain current. Not a first book — pair with ISLR for beginners. Bishop's newer "Deep Learning: Foundations and Concepts" (2023) is the spiritual successor covering modern deep learning.
- **Confidence**: [Verified]
- **Score**: 4.15

#### The Hundred-Page Machine Learning Book
- **Type**: Book
- **Author(s)**: Andriy Burkov
- **Year**: 2019
- **ISBN**: 978-1999579500 [Verified]
- **Publisher**: Self-published
- **Difficulty**: Beginner to Intermediate
- **Time Estimate**: ~8-12 hours
- **Synopsis**: Compact overview of ML fundamentals in approximately 150 pages. Covers supervised/unsupervised learning, neural networks, and practical considerations. Good as a quick survey or refresher, but insufficient depth for primary learning. Endorsed by several ML researchers.
- **Prerequisites**: Basic math literacy, some programming awareness
- **Sourcing**: Purchase ~$30 (Amazon) | "Read first, buy later" policy from author
- **Notes**: Self-published but well-reviewed and community-endorsed. Best used as a rapid overview before diving into a more comprehensive resource, or as a concise refresher.
- **Confidence**: [Verified]
- **Score**: 3.35

#### Machine Learning: A Probabilistic Perspective
- **Type**: Book
- **Author(s)**: Kevin P. Murphy
- **Year**: 2012
- **ISBN**: 978-0262018029 [Verified]
- **Publisher**: MIT Press
- **Difficulty**: Advanced
- **Time Estimate**: ~100-150 hours (reference — not cover-to-cover)
- **Synopsis**: Encyclopedic treatment of machine learning from a probabilistic viewpoint. Covers essentially everything: generative and discriminative models, graphical models, inference, optimization, deep learning, nonparametric methods. Over 1000 pages. Functions as both textbook and reference.
- **Prerequisites**: Strong linear algebra, probability, statistics, mathematical maturity
- **Sourcing**: Purchase ~$90 | Library
- **Notes**: Murphy published a two-volume successor, "Probabilistic Machine Learning: An Introduction" (2022) and "Probabilistic Machine Learning: Advanced Topics" (2023), both freely available as PDFs from probml.github.io. The 2022/2023 versions are more current and are recommended over the 2012 edition.
- **Confidence**: [Verified]
- **Score**: 4.00

---

### Articles and Tutorials

#### A Visual Introduction to Machine Learning
- **Type**: Interactive Article
- **Author(s)**: R2D3 (Stephanie Yee and Tony Chu)
- **URL**: http://www.r2d3.us/visual-intro-to-machine-learning-part-1/ [Unverified]
- **Difficulty**: Beginner
- **Time Estimate**: ~30 minutes
- **Synopsis**: Beautifully crafted interactive visualization explaining how machine learning works using a decision tree classifying San Francisco vs New York apartments. Scrollytelling format makes abstract concepts tangible. Part 2 covers bias-variance tradeoff.
- **Notes**: Exceptional for absolute beginners or as a hook before formal study. Short but memorable.
- **Confidence**: [Moderate confidence]
- **Score**: 3.75

#### A Few Useful Things to Know About Machine Learning
- **Type**: Article (published in Communications of the ACM)
- **Author(s)**: Pedro Domingos
- **Year**: 2012
- **DOI**: 10.1145/2347736.2347755 [Verified]
- **Difficulty**: Intermediate
- **Time Estimate**: ~1-2 hours
- **Synopsis**: Twelve key lessons for ML practitioners covering generalization, data vs algorithms, feature engineering, overfitting, ensembles, and the curse of dimensionality. Concise, opinionated, and widely cited. Functions as a "wisdom of the field" summary that complements any textbook.
- **Prerequisites**: Basic ML vocabulary (knows what classification and regression mean)
- **Sourcing**: Free PDF widely available | ACM Digital Library
- **Notes**: At ~9000 citations, this is one of the most-read ML papers. Essential reading after completing an introductory course or book. Short enough to read in one sitting.
- **Confidence**: [Verified]
- **Score**: 3.80

#### Google's Machine Learning Crash Course
- **Type**: Interactive Tutorial
- **Author(s)**: Google
- **URL**: https://developers.google.com/machine-learning/crash-course [Unverified]
- **Platform**: Google Developers
- **Difficulty**: Beginner
- **Time Estimate**: ~15 hours
- **Synopsis**: Free interactive course with video lectures, readings, and hands-on exercises using TensorFlow. Covers ML fundamentals: linear regression, logistic regression, regularization, neural networks, embeddings, and ML engineering. Developed by Google engineers for internal training, then released publicly.
- **Prerequisites**: Basic Python, introductory algebra
- **Sourcing**: Free
- **Notes**: Practical orientation — good for engineers who want to apply ML quickly. Less theoretical depth than ISLR but more hands-on. Pairs well with a textbook for theory.
- **Confidence**: [Moderate confidence]
- **Score**: 3.60

---

### Academic Papers

#### A Survey of Deep Learning Techniques
- **Type**: Survey Paper
- **Author(s)**: Laith Alzubaidi et al.
- **Year**: 2021
- **DOI**: 10.1186/s40537-021-00444-8 [Verified]
- **Difficulty**: Intermediate to Advanced
- **Time Estimate**: ~4-6 hours
- **Synopsis**: Comprehensive survey covering deep learning architectures (CNNs, RNNs, autoencoders, GANs, transformers), training techniques, transfer learning, and applications. Includes practical guidance on when to use which architecture. Published in Journal of Big Data (open access).
- **Sourcing**: Open Access (SpringerOpen)
- **Notes**: Useful as a map of the deep learning landscape after learning fundamentals. Not a first resource — assumes basic ML knowledge.
- **Confidence**: [Verified]
- **Score**: 3.50

#### A Tutorial on Support Vector Machines for Pattern Recognition
- **Type**: Tutorial Paper
- **Author(s)**: Christopher J.C. Burges
- **Year**: 1998
- **DOI**: 10.1023/A:1009715923555 [Verified]
- **Difficulty**: Intermediate
- **Time Estimate**: ~3-4 hours
- **Synopsis**: Classic tutorial that made SVMs accessible to practitioners. Builds intuition from linear classifiers through kernel methods with clear geometric explanations. Despite its age, it remains one of the clearest expositions of the SVM framework.
- **Notes**: Foundational — SVMs are less trendy now but the concepts (margin maximization, kernel trick, regularization) are permanent. Still widely assigned in courses.
- **Confidence**: [Verified]
- **Score**: 3.40

---

### Open-Access Courses and Materials

#### Stanford CS229: Machine Learning (Andrew Ng)
- **Type**: Video Course (Full University Lectures)
- **Author(s)**: Andrew Ng
- **URL**: Available on YouTube (search "Stanford CS229" for latest offering) [Unverified]
- **Platform**: Stanford Online / YouTube
- **Difficulty**: Intermediate
- **Time Estimate**: ~40-50 hours (lectures + problem sets)
- **Synopsis**: The course that sparked the modern ML education movement. Covers supervised learning (regression, classification, SVMs, neural networks), unsupervised learning (clustering, dimensionality reduction, anomaly detection), and reinfortic learning basics. Mathematical rigor with practical applications. Lecture notes and problem sets available.
- **Prerequisites**: Linear algebra, probability and statistics, Python or MATLAB
- **Sourcing**: Free (YouTube lectures, course website for notes)
- **Notes**: Multiple offerings exist on YouTube from different years. The course website (cs229.stanford.edu) has notes and problem sets. More mathematical than the Coursera specialization — choose based on desired rigor.
- **Confidence**: [High confidence]
- **Score**: 4.75

#### fast.ai — Practical Deep Learning for Coders
- **Type**: Video Course + Interactive Notebooks
- **Author(s)**: Jeremy Howard, Rachel Thomas
- **URL**: https://course.fast.ai/ [Unverified]
- **Platform**: fast.ai
- **Difficulty**: Beginner to Intermediate (top-down approach)
- **Time Estimate**: ~30-40 hours
- **Synopsis**: Unique "top-down" approach: start with working deep learning models, then progressively understand the internals. Covers image classification, NLP, tabular data, and collaborative filtering using the fastai library (built on PyTorch). Free, with active forums and community.
- **Prerequisites**: Python programming (1+ year experience recommended)
- **Sourcing**: Free (course.fast.ai)
- **Notes**: Deliberately inverts the traditional bottom-up approach. May frustrate learners who prefer mathematical foundations first — pair with ISLR or PRML for theory. The fast.ai library is opinionated but excellent for rapid prototyping.
- **Confidence**: [High confidence]
- **Score**: 4.65

#### Coursera Machine Learning Specialization
- **Type**: MOOC (3-course specialization)
- **Author(s)**: Andrew Ng, with Stanford Online and DeepLearning.AI
- **URL**: https://www.coursera.org/specializations/machine-learning-introduction [Unverified]
- **Platform**: Coursera
- **Difficulty**: Beginner
- **Time Estimate**: ~60-80 hours (3 courses)
- **Synopsis**: Updated version of Ng's original 2011 ML course (one of the most popular online courses ever). Three courses covering supervised learning, advanced algorithms, and unsupervised learning/recommender systems. Uses Python (the original used Octave). Quizzes and programming assignments throughout.
- **Prerequisites**: Basic Python, high school math
- **Sourcing**: Free to audit | Certificate: ~$50/month (Coursera Plus)
- **Notes**: The 2022 version is a ground-up rewrite in Python. Less mathematical than CS229 but more accessible. Excellent starting point for career switchers or self-taught developers.
- **Confidence**: [High confidence]
- **Score**: 4.55

#### Mathematics for Machine Learning
- **Type**: Open Textbook
- **Author(s)**: Marc Peter Deisenroth, A. Aldo Faisal, Cheng Soon Ong
- **Year**: 2020
- **URL**: https://mml-book.github.io/ [Unverified]
- **Publisher**: Cambridge University Press
- **Difficulty**: Beginner to Intermediate (math), Prerequisite for ML
- **Time Estimate**: ~40-60 hours
- **Synopsis**: Fills the math gap between high school and ML textbooks. Part I covers linear algebra, analytic geometry, matrix decompositions, probability, and optimization. Part II applies these to regression, dimensionality reduction, density estimation, and classification. Available as free PDF.
- **Prerequisites**: Comfort with basic algebra and notation
- **Sourcing**: Free PDF (mml-book.github.io) | Purchase print edition ~$45
- **Notes**: Categorized as a prerequisite resource, not an ML textbook itself. Strongly recommended before tackling Bishop (PRML) or Murphy. The free PDF makes it an essential recommendation for anyone who feels shaky on the math.
- **Confidence**: [High confidence]
- **Score**: 4.30

#### MIT 6.034 Artificial Intelligence (Patrick Winston)
- **Type**: Video Course (Full University Lectures)
- **Author(s)**: Patrick Henry Winston
- **URL**: https://ocw.mit.edu/courses/6-034-artificial-intelligence-fall-2010/ [Unverified]
- **Platform**: MIT OpenCourseWare
- **Difficulty**: Intermediate
- **Time Estimate**: ~30-40 hours
- **Synopsis**: Classic MIT AI course covering search, constraint satisfaction, learning (neural nets, SVMs, boosting), representations, and AI philosophy. Winston's teaching style is legendary — clear, engaging, and deeply thoughtful. Covers broader AI context beyond just ML.
- **Prerequisites**: Programming experience, basic discrete math
- **Sourcing**: Free (MIT OCW)
- **Notes**: Recorded in 2010 — pre-deep-learning-revolution. Valuable for foundational AI concepts and reasoning approaches, less so for modern deep learning practice. Winston passed away in 2019; these lectures are part of his enduring legacy.
- **Confidence**: [High confidence]
- **Score**: 3.90

---

## Coverage Summary

### What Was Covered

| Source Type | Resources Found | Quality Range |
|---|---|---|
| Books | 5 | 3.35 - 5.00 |
| Articles/Tutorials | 3 | 3.60 - 3.80 |
| Academic Papers | 2 | 3.40 - 3.50 |
| Open-Access Courses | 5 | 3.90 - 4.75 |
| **Total** | **15** | |

### Recommended Starting Points (by level)

| Level | Start With | Then |
|---|---|---|
| **Complete beginner** | Coursera ML Specialization (Ng) or Google Crash Course | ISLR + fast.ai |
| **Some programming, no ML** | ISLR (free PDF) + fast.ai | Hands-On ML (Geron) |
| **Math-comfortable** | ISLR → PRML (Bishop) | CS229 lectures |
| **Wants math foundations first** | Mathematics for ML (Deisenroth) | ISLR → Bishop |
| **Practitioner wanting depth** | Hands-On ML (Geron) + Murphy (2022/2023 free PDFs) | Survey papers |

### Gaps and Limitations

- **Reinforcement learning**: Not well-covered in this bibliography. A dedicated search for RL resources would be needed (Sutton & Barto is the canonical text).
- **MLOps / deployment**: Touched on in Geron but not a primary focus of any listed resource. Separate research session recommended.
- **Domain-specific ML** (NLP, computer vision, time series): Each warrants its own research session with targeted searches.
- **Non-English resources**: Not searched. Significant ML education content exists in Mandarin, Spanish, and other languages.
- **Some URLs marked [Unverified]**: These were not fetched during the session. Verify before sharing with end user.

### Output Format Reference

Each bibliography entry follows this schema (from SKILL.md):

```markdown
### [Title]
- **Type**: Book | Article | Paper | Video Course | Open Textbook
- **Author(s)**: Name(s)
- **Year**: Publication year
- **ISBN/DOI/URL**: Identifier or link
- **Difficulty**: Beginner | Intermediate | Advanced | Expert
- **Time Estimate**: ~X hours
- **Synopsis**: 2-3 sentences
- **Prerequisites**: What the reader should know first
- **Sourcing**: Purchase | Library | Open Access (with specifics)
- **Notes**: Caveats, edition recommendations, companion resources
- **Confidence**: [Verified] | [High confidence] | [Moderate confidence] | [Unverified]
- **Score**: Weighted quality score (1.00 - 5.00)
```
