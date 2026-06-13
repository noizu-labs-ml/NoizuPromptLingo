---
id: P-004
name: "Daniel Reyes"
slug: "iot-product-manager"
archetype: "IoT Product Manager"
segment: "secondary"
tags: [iot, embedded-systems, firmware, espressif, arm, fleet-management, hardware, product-management]
---

# Daniel Reyes — IoT Product Manager

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 30–42 |
| **Role** | Product Manager / Head of Hardware Products |
| **Technical Level** | Intermediate |
| **Industry** | Industrial IoT, Smart Home, AgriTech, Energy, Medical Devices |
| **Location** | US, Germany, or Australia |

## Bio

Daniel owns the product roadmap for a connected hardware device that monitors industrial equipment. He understands product deeply but is increasingly stretched by the technical complexity of the firmware layer — his small embedded team is bottlenecked, OTA update reliability is poor, and the fleet of 3,000 deployed devices is increasingly hard to manage. He needs senior embedded systems expertise to unblock his roadmap and establish a scalable firmware architecture.

## Goals

1. Establish a reliable OTA update pipeline for a fleet of 3,000+ ESP32 devices
2. Refactor the firmware architecture to support multiple hardware SKUs without forking the codebase
3. Build out internal embedded systems capability through mentorship of his junior engineer

## Frustrations

1. Consultants who know software but not embedded constraints (power budgets, memory, real-time constraints)
2. Firmware bugs that are hard to reproduce in the lab but surface consistently in the field
3. No systematic approach to fleet telemetry — problems are discovered by customers, not monitoring

## Behaviors

- Searches GitHub for open-source IoT frameworks and reads commit histories to evaluate expertise
- Attends Embedded World, CES, or online IoT-specific communities (Nordic DevZone, Espressif forums)
- Evaluates consultants by asking specific technical questions before any commercial conversation
- Wants proof of hands-on hardware work, not just architecture diagrams

## Job to Be Done

> "When my firmware team is bottlenecked and my fleet is growing faster than my ability to manage it reliably, I want an embedded systems expert who has actually shipped hardware products at scale, so I can unblock my roadmap and stop firefighting in production."

## Relationship to Product

Discovers noizu.com through GitHub (Noizu GenAI / embedded-related work), a conference referral, or a targeted LinkedIn search for ESP32/ARM consulting. The IoT & Embedded Systems service page is the primary landing point — it must signal hands-on expertise with specific chips and frameworks, not generic "IoT solutions." Submits an RFI with technical context (chip family, RTOS, fleet size, specific pain points). Less interested in the client dashboard polish; cares most about clear deliverable definitions and access to Keith's actual work product.

## Scenarios

1. **OTA architecture review** — Needs a design document and proof-of-concept for a phased OTA update system supporting rollback and A/B deployment across heterogeneous ESP32 hardware revisions
2. **Fleet observability setup** — Wants to instrument 3,000 deployed devices with lightweight telemetry and build a simple ops dashboard without requiring a device-side firmware update
