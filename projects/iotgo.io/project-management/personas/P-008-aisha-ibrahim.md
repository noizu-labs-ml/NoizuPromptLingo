---
id: P-008
name: "Aisha Ibrahim"
slug: "aisha-ibrahim"
archetype: "Field Operator / Junior IoT Technician"
segment: "tertiary"
tags: [field-operator, mobile-first, end-user, manual-steps, alert-recipient, novice, on-the-floor]
---

# Aisha Ibrahim — Field Operator / Junior IoT Technician

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 22–30 |
| **Role** | IoT Field Technician / Facilities Technician |
| **Technical Level** | Novice |
| **Industry** | Manufacturing / Facilities |
| **Location** | Southeast, USA |

## Bio

Aisha joined the maintenance team at a food processing facility 18 months ago after completing a technical certificate program in industrial systems. She is responsible for responding to device alerts, performing physical interventions on sensors and controllers the autonomous agents flag for manual attention, and logging outcomes. She does not configure IoTGo — that is her supervisor's job — but she interacts with it daily through her phone and a shared tablet on the plant floor. The quality of her experience determines whether the human-in-the-loop steps in the automation workflow actually get executed correctly and on time.

## Goals

1. Receive clear, specific instructions when an agent escalates a task to her — not a raw telemetry alert, but a plain-language action: "Go to Zone 4, check the sensor on Tank 7, press the reset button."
2. Log intervention outcomes quickly while she is physically at the device — she does not want to remember what she did and fill out a form back at a desk.
3. Understand whether her manual action resolved the issue or whether she needs to escalate to her supervisor.

## Frustrations

1. Alert notifications she currently receives are cryptic — "Device ID d-4482: threshold breach 0x03" — and she has to ask her supervisor what to do, wasting time.
2. The current logging process requires her to fill out a paper form after each intervention and then enter it into a computer at the end of her shift; she forgets details.
3. She often does not know whether the problem was actually resolved after she acts — there is no feedback loop to tell her if the sensor recovered.

## Behaviors

- Works primarily from her phone on the plant floor; her laptop stays at her desk.
- Responds to push notifications and follows step-by-step checklists; cognitive load during physical work is high.
- Texts her supervisor photos of physical issues she encounters during interventions as informal documentation.
- Feels more confident and competent when she has a clear procedure to follow; ambiguous tasks cause anxiety and delay.
- Shifts rotate; she needs context on what previous shifts did before her, without reading through a long log.

## Job to Be Done

> "When an agent escalates a task to me, I need a plain-English description of what to do, step-by-step instructions I can follow on my phone while walking to the device, and immediate confirmation that my action resolved the issue — so I can close the task and move to the next one."

## Relationship to Product

Aisha does not choose IoTGo — it is deployed by her supervisors. Her experience is defined by how well the platform's mobile interface handles agent escalations to human operators. The key workflow for her: push notification → tap to open task → read plain-language summary of what the agent detected → follow numbered intervention checklist → tap "Done" at the device → see a confirmation that telemetry recovered. If this workflow is clear and fast, she becomes an enthusiastic user who tells her supervisor "the app actually makes my job easier." If notifications are cryptic or the mobile UI requires too many taps, she ignores IoTGo and reverts to calling her supervisor directly. She is the persona whose adoption failure most damages the platform's value proposition at the operational level.

## Scenarios

1. **The Clean Escalation** — At 10:15am, Aisha's phone buzzes with an IoTGo push notification: "Action needed — Tank 7 temperature sensor (Zone 4) is reading inconsistently. Possible loose connector. Steps: (1) Go to Tank 7 in Zone 4. (2) Check the sensor cable at the junction box. (3) Reseat the connector if loose. (4) Tap Done." She walks to Zone 4, finds the connector slightly unseated from a vibration event, reseats it, taps Done on her phone, and receives: "Sensor recovered. Temperature reading is stable. Task closed." Total time: 8 minutes.

2. **The Shift Handoff** — Aisha starts her afternoon shift and opens IoTGo's mobile dashboard. She sees a "Shift Summary" card: two tasks completed by the morning team (both resolved), one task currently in-progress by an agent (monitoring a motor vibration anomaly, no human action needed yet), and one open escalation from two hours ago that was snoozed pending a parts delivery. She has full context in under a minute and knows exactly what needs attention.
