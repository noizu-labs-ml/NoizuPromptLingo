# Persona 04: The Educator

**Name:** Dr. Maria Santos
**Age:** 42
**Location:** Austin, TX
**Occupation:** High school computer science teacher, part-time adjunct at community college
**Device:** Google Pixel 8, Chromebook for classroom
**Income:** $68K/year

---

## Profile

Maria teaches AP Computer Science and an intro-to-AI elective. She's constantly looking for tools that make abstract CS concepts tangible for 16-18 year olds. She's used Scratch, code.org, and even had students build simple chatbots, but she's never found a good tool for teaching neural network concepts without requiring calculus or Python.

AI Fighter's graph editor is, to her, a teaching instrument disguised as a game. The visual node editor maps directly to concepts she teaches: inputs (perception), processing (decision weights), and outputs (actions). The training gym demonstrates reinforcement learning without a single line of code. She doesn't care about ranked play — she cares about lesson plans.

---

## Goals

- Use AI Fighter as a classroom tool for teaching neural network fundamentals
- Create structured assignments: "Build a fighter that prioritizes defense. Explain why you chose these weights."
- Have students compete against each other's fighters as a unit project
- Demonstrate concepts like overfitting (fighter that beats one archetype but loses to everything else) through gameplay

## Frustrations

- Educational tools that are either too simplistic (no depth) or too complex (require prerequisites her students don't have)
- Games with in-app purchases, ads, or inappropriate content — school policies block these
- No way to create "sandboxed" environments where students can experiment without encountering the wider community
- Lack of lesson plan resources or curriculum integration guides

## Behaviors

- Downloads the game months before using it in class to evaluate thoroughly
- Creates a controlled classroom environment: students compete only against each other or against training bots
- Documents student builds and training data as assessment artifacts
- Shares curriculum materials with other CS teachers in professional networks
- Will NOT spend money on the game — school budget covers nothing, and she won't ask students to pay

---

## Key Scenarios

1. **Evaluation phase:** Downloads the game, plays through onboarding, verifies there's no inappropriate content, tests whether students can use it without accounts (or with school-managed accounts)
2. **Classroom use:** 25 students each build a fighter over a 2-week unit. They write reflection papers on how their graph design maps to neural network concepts. Final class tournament with replays projected on the smartboard
3. **Advocacy:** Writes a blog post for the CSTA (CS Teachers Association) about using AI Fighter to teach machine learning concepts. Tags the AI Fighter social accounts

---

## Design Implications

- A "Classroom Mode" or educator program would unlock massive word-of-mouth growth in the K-12 and college market
- The free tier must be fully functional for educational use — no paywalled nodes that a teacher needs for a lesson
- Content moderation in build names, clan names, and any UGC is critical — one inappropriate clan name kills classroom adoption
- Export/documentation of a fighter's training history (generation-by-generation performance data) becomes a pedagogical tool
- Consider an API or data export for graph definitions (JSON is already planned) that teachers could use for assignments
- COPPA compliance is required if targeting under-13 (likely not MVP, but worth planning)
