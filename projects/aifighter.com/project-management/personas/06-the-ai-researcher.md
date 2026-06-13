# Persona 06: The AI Researcher

**Name:** Dr. Priya Sharma
**Age:** 35
**Location:** Cambridge, MA
**Occupation:** Postdoctoral researcher in reinforcement learning at MIT
**Device:** iPhone 14 Pro, MacBook Pro (primary)
**Income:** $75K/year

---

## Profile

Priya studies multi-agent reinforcement learning and is always looking for accessible demonstrations of RL concepts. She found AI Fighter through a colleague's Twitter thread comparing its graph editor to simplified versions of decision-making architectures she publishes papers about. She's not a gamer — she's a researcher who sees the game as an experiment in democratizing AI concepts.

She's interested in the gap between what the game promises ("you're building a neural net") and what it actually delivers (a constrained decision graph with trained weights). She'll probe that gap relentlessly. If the game's training system is genuinely interesting from an RL perspective, she'll write about it. If it's smoke and mirrors with preset behavior trees, she'll lose interest immediately.

---

## Goals

- Understand the actual computational model underlying the "neural net" metaphor — is it genuinely learning or just parameter tuning?
- Use the game as a demonstration tool in talks and lectures ("Here's RL concepts explained through a game anyone can play")
- Explore emergent behaviors: do complex graphs produce strategies the designer didn't anticipate?
- Potentially collaborate with the dev team on making the training system more scientifically rigorous

## Frustrations

- Marketing that overpromises the "AI" angle — if the fighters don't genuinely learn, calling it a neural net is misleading
- No access to the underlying model or training data beyond surface-level analytics
- Lack of reproducibility — if she runs the same training twice, do the results differ? Is there a seed?
- The game treating the graph as a black box when she wants to inspect every weight and gradient

## Behaviors

- Plays infrequently (2-3 sessions per week) but analyzes deeply when she does
- Screenshots training data graphs and compares them to RL reward curves from her research
- Asks technical questions in community forums that most players can't answer
- Will write a blog post or tweet thread about the game's AI model if she finds it genuinely interesting
- Will not spend any money on the game — her engagement is intellectual, not competitive

---

## Key Scenarios

1. **First session:** Ignores cosmetics and ranking entirely. Builds a minimal 3-node graph and a complex 15-node graph. Trains both for 50 generations. Compares performance curves. Asks: "Is the complex graph actually better, or does it overfit?"
2. **Week 2:** Has DM'd the dev team asking for technical documentation on the training algorithm. Has posted on Twitter: "AI Fighter's training gym is actually a [simplified policy gradient / behavior tree / etc.] — here's why that's [cool / misleading]"
3. **Month 1:** Either: (a) has become an advocate, citing the game in a conference talk about accessible RL, or (b) has moved on because the underlying model wasn't interesting enough to sustain her attention

---

## Design Implications

- The training system's actual mechanism should be documentable and defensible — if researchers call it fake, that narrative will spread
- Providing a "technical details" panel (hidden behind an advanced toggle) showing training loss curves, weight updates, and generation deltas would delight this persona without cluttering the main UI
- Reproducibility options (set a training seed, replay exact same training run) enable both research use and competitive fairness discussions
- The JSON graph export format should include training history metadata, not just the final weights
- This persona is a credibility amplifier — if Priya tweets "this is legit RL," it validates the product for the entire Tinkerer segment
