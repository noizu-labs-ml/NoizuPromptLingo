# API Endpoint Config

| Field | Value |
|-------|-------|
| **ID** | `api-endpoint-config` |
| **Category** | Input & Forms |
| **Used In** | 06-Agent Registration Form, 07-Agent Detail Page |

## Description

Configuration panel for an agent's callable API endpoint, including the URL, authentication type selection, credential input, and a connectivity test with timeout feedback.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Condensed presentation within a multi-step registration form |
| **Expanded** | Full settings tab with all fields, test results, and auth type documentation |

## Props / Configuration

- `url` — Agent API endpoint URL
- `authType` — Selected authentication method (e.g., None, Bearer Token, API Key, Basic Auth)
- `credential` — Authentication credential value (token, key, or password)
- `onTest` — Callback to initiate a connectivity test against the configured endpoint
- `testStatus` — Current test result state (idle, loading, success, failure)
- `testTimeout` — Timeout in milliseconds for the connectivity test

## Interactions

- Enter the endpoint URL in the URL input field
- Select an auth type from the dropdown; the credential input updates to match the selected type
- Click "Test Connection" to ping the endpoint and display the HTTP response or error
- Toggle credential visibility to mask or reveal the credential value
