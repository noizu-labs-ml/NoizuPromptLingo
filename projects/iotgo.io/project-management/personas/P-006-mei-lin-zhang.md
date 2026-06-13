---
id: P-006
name: "Mei-Lin Zhang"
slug: "mei-lin-zhang"
archetype: "Data Scientist / ML Engineer"
segment: "secondary"
tags: [data-science, ml, anomaly-detection, model-tuning, python, technical, researcher, advanced-user]
---

# Mei-Lin Zhang — Data Scientist / ML Engineer

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 28–36 |
| **Role** | Senior ML Engineer / IoT Analytics Lead |
| **Technical Level** | Expert |
| **Industry** | Industrial IoT / Smart Energy |
| **Location** | San Francisco Bay Area |

## Bio

Mei-Lin works on the data science team at a smart grid company that manages distributed energy resources — solar inverters, battery storage, EV chargers — across 50,000+ connected devices. She was hired to build anomaly detection models from scratch on top of raw telemetry, and she has published two internal papers on multivariate time series anomaly detection specific to their device fleet. She is evaluating IoTGo's Anomaly Detection Engine because her team is drowning in model maintenance and wants to understand if a purpose-built platform can replace or augment their homegrown pipeline without sacrificing explainability.

## Goals

1. Understand the anomaly detection models powering IoTGo deeply enough to determine whether they can match or exceed her team's custom models on her specific device classes.
2. Access model parameters, feature importance, and detection confidence scores — not just binary alert/no-alert outputs — so anomaly signals can feed into her existing MLOps pipeline.
3. Reduce the time her team spends on model maintenance and retraining so they can focus on higher-value predictive analytics work.

## Frustrations

1. Black-box anomaly detection is a non-starter — she cannot defend an alert to engineers if she cannot explain why the model flagged it.
2. Most IoT platforms treat anomaly detection as a feature, not a domain; the default models are generic threshold rules with "AI" marketing copy pasted over them.
3. IoTGo's public documentation doesn't specify which anomaly detection algorithms are used, what the training data assumptions are, or how models adapt to seasonal patterns — she needs to find this information before she can evaluate seriously.

## Behaviors

- Reads academic papers before vendor docs; if a product's anomaly detection isn't grounded in peer-reviewed methodology she will dismiss it.
- Runs all new tools in Jupyter notebooks first, interfacing via API, before touching any UI.
- Has a private benchmark dataset — six months of labeled anomalies from their fleet — that she uses to evaluate all new detection systems.
- Participates in the PyData and MLOps communities; will share evaluation results publicly if IoTGo impresses or disappoints.
- Measures detection quality in precision/recall/F1, not "reduced alerts" marketing metrics.

## Job to Be Done

> "When IoTGo flags an anomaly on a solar inverter, I need to see why it flagged it — which features drove the score, how confident the model is, and how that confidence changes over time as the model learns — so I can trust the signal and integrate it into our decision pipeline."

## Relationship to Product

Mei-Lin discovers IoTGo through a mention on the MLOps Community Slack or a blog post comparing time-series anomaly detection platforms. She signs up for a free account specifically to access the Anomaly Detection Engine API. Her first move is to call the API with telemetry from her benchmark dataset and compare IoTGo's detection output against her team's labeled ground truth. If IoTGo exposes model confidence scores, feature attribution, and a model feedback endpoint, she proceeds. If it returns only binary alerts with no explainability, she closes the tab. Long-term, she is interested in contributing custom model configurations and potentially co-authoring a technical blog post with IoTGo if results are good. Churn risk: any regression in detection quality after a silent model update she wasn't notified about.

## Scenarios

1. **The Benchmark Evaluation** — Mei-Lin uploads six months of labeled inverter anomalies to IoTGo via the telemetry replay API. She compares detection precision and recall against her team's isolation forest baseline. IoTGo achieves 84% recall vs. her baseline's 79% on the hardest class (intermittent ground faults). She notes IoTGo's model struggles on rapid-onset faults and opens a feature request for configurable detection sensitivity by device class.

2. **The Explainability Deep Dive** — IoTGo's agent flags an anomaly on a battery storage unit. Mei-Lin pulls the anomaly event via API and inspects the payload: the response includes a confidence score (0.91), a feature importance breakdown showing voltage ripple and temperature deviation as primary contributors, and a rolling baseline comparison for the past 30 days. She approves the signal for integration into the team's real-time decision system.
