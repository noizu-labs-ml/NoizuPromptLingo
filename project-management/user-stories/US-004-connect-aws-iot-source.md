---
id: US-004
title: "Connect AWS IoT Core as Data Source"
slug: "connect-aws-iot-source"
personas: [P-001, P-004]
epic: "Onboarding & Fleet Connection"
priority: "must-have"
complexity: "M"
tags: [onboarding, aws, integration, data-source, cloud]
---

# US-004: Connect AWS IoT Core as Data Source

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** connect my AWS IoT Core account to IoTGo using IAM credentials or a role ARN,
**So that** the platform can read device telemetry and shadow state without manual data pipeline work.

## Acceptance Criteria

- [ ] Given I select "AWS IoT Core" as the source type, when the connection form renders, then I can provide either an IAM Access Key/Secret or a cross-account Role ARN and external ID.
- [ ] Given I submit valid AWS credentials, when IoTGo validates them, then the system confirms the required IAM permissions (iot:DescribeEndpoint, iot:ListThings, iot:Subscribe) are present and reports any missing permissions explicitly.
- [ ] Given a successful AWS connection, when the system syncs, then it imports the thing registry metadata (thing names, types, groups, attributes) within 60 seconds for fleets up to 10K devices.
- [ ] Given I choose Role ARN auth, when the connection is saved, then IoTGo displays the IoTGo AWS account ID and the trust policy snippet I need to add to my role.

## Notes

Cross-account role assumption is the preferred enterprise pattern; IAM key/secret should show a deprecation nudge for production use. Azure IoT Hub connection is covered in US-005.
