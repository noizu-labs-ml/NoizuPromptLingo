# Compliance & Licensing for MCP Servers

> Legal and compliance considerations for building and distributing MCP servers. Covers open source licensing, API terms of service, data privacy, and enterprise compliance.

---

## Open Source License Selection

### License Comparison for MCP Servers

| License | Permissive? | Requires Attribution? | Copyleft? | Patent Grant? | Best For |
|---------|------------|----------------------|-----------|---------------|----------|
| **MIT** | Yes | Yes (minimal) | No | No | Maximum adoption, minimal restrictions |
| **Apache 2.0** | Yes | Yes | No | Yes | Enterprise-friendly, patent protection |
| **ISC** | Yes | Yes (minimal) | No | No | Simplified MIT equivalent |
| **GPL v3** | No | Yes | Yes (strong) | Yes | Ensuring derivatives remain open |
| **AGPL v3** | No | Yes | Yes (network) | Yes | Preventing SaaS free-riding |
| **BSL / SSPL** | No | Varies | Source-available | Varies | Commercial protection with open source optics |

### Recommendations

**For public MCP servers seeking adoption:** MIT or Apache 2.0

- MIT is the most common choice in the JavaScript/TypeScript ecosystem
- Apache 2.0 adds an explicit patent grant, which enterprises prefer

**For MCP servers wrapping proprietary logic:** Apache 2.0

- Patent grant protects both you and users
- Permissive enough for enterprise adoption

**For MCP servers you want to keep open:** AGPL v3

- Prevents others from running your server as a closed SaaS
- Note: significantly reduces enterprise adoption (many companies prohibit AGPL dependencies)

### Dependency License Compatibility

When your MCP server depends on libraries, their licenses flow into your distribution:

| Your License | Can Depend On |
|-------------|---------------|
| MIT | MIT, ISC, BSD, Apache 2.0, public domain |
| Apache 2.0 | MIT, ISC, BSD, Apache 2.0, public domain |
| GPL v3 | All of the above + GPL v2/v3 |
| AGPL v3 | All of the above + AGPL v3 |

**Red flags:**
- GPL dependency in an MIT-licensed project (license conflict)
- AGPL dependency in any permissively-licensed project
- License not specified on a dependency (treat as proprietary until clarified)

---

## API Terms of Service Compliance

### When Your MCP Server Wraps a Third-Party API

Most APIs have Terms of Service that restrict how their data can be used. Common restrictions:

| Restriction | How It Affects MCP Servers | Mitigation |
|------------|---------------------------|------------|
| **Rate limits** | Your server must not exceed upstream limits | Implement rate limiting, caching |
| **Attribution** | Must credit the data source | Include attribution in tool results |
| **Commercial use** | Free tier may prohibit commercial use | Use commercial API tier if selling access |
| **Redistribution** | May not store/redistribute data | Cache only transiently, don't persist |
| **Modification** | May not alter data | Return data as-is, label any transformations |
| **Competitive use** | May not use to build a competing product | Ensure your server doesn't compete with the API provider |

### Pre-Flight Checklist for API Wrapping

- [ ] Read the API's Terms of Service completely
- [ ] Identify rate limits and implement server-side enforcement
- [ ] Check if commercial use is permitted under your API tier
- [ ] Check redistribution/caching restrictions
- [ ] Check attribution requirements
- [ ] Verify your use case is not prohibited (competitive use, scraping, etc.)
- [ ] Document which API plan you are using and its limits
- [ ] Plan for API deprecation or terms changes

### Common API Terms Gotchas

| API Provider | Common Restriction | Impact |
|-------------|-------------------|--------|
| OpenAI | Output cannot train competing models | If MCP tool results feed into training, this applies |
| Google Maps | Cannot cache results >30 days | Limit cache TTL |
| Twitter/X | Cannot redistribute tweets in bulk | Limit result counts |
| GitHub | Rate limits per token (5000/hr) | Implement per-user token flow |
| Stripe | PCI compliance for payment data | Do not log or cache card numbers |

---

## Data Privacy

### GDPR (EU)

If your MCP server processes data from EU residents:

| Requirement | What It Means for MCP Servers |
|------------|------------------------------|
| **Lawful basis** | You need a legal reason to process personal data (consent, legitimate interest, contract) |
| **Data minimization** | Only collect/process data needed for the tool's function |
| **Right to access** | Users can request all data you hold about them |
| **Right to erasure** | Users can request deletion of their data |
| **Data portability** | Users can request their data in a machine-readable format |
| **Breach notification** | 72-hour notification requirement for data breaches |
| **DPA** | Data Processing Agreement required with sub-processors |

### CCPA (California)

If your MCP server handles data from California residents:

| Requirement | What It Means |
|------------|---------------|
| **Right to know** | Disclose what personal data you collect and why |
| **Right to delete** | Honor deletion requests |
| **Right to opt-out** | Allow opting out of data selling |
| **Non-discrimination** | Cannot penalize users who exercise their rights |

### Privacy-by-Design Checklist

- [ ] Identify all personal data the server processes
- [ ] Document the lawful basis for processing each type
- [ ] Implement data minimization (don't collect what you don't need)
- [ ] Set data retention periods (and enforce them)
- [ ] Implement deletion capability for user data
- [ ] Encrypt personal data at rest and in transit
- [ ] Log access to personal data (audit trail)
- [ ] Publish a privacy policy if the server is public
- [ ] Identify and document all sub-processors (databases, APIs, logging services)

### Data in Tool Results

MCP tool results flow to LLM clients and may be stored in conversation history. Consider:

- Do tool results contain personal data? (names, emails, addresses)
- Can you anonymize or pseudonymize data before returning it?
- Should you redact sensitive fields (SSN, credit card numbers)?
- Does the client store conversation history? (You may not control this)

---

## SOC 2 Considerations

For enterprise MCP servers, SOC 2 compliance may be required.

### Relevant Trust Service Criteria

| Criteria | MCP Server Relevance |
|----------|---------------------|
| **Security** | Access controls, encryption, vulnerability management |
| **Availability** | Uptime SLA, monitoring, disaster recovery |
| **Processing Integrity** | Input validation, output accuracy, error handling |
| **Confidentiality** | Data classification, access logging, encryption |
| **Privacy** | Personal data handling (see GDPR/CCPA above) |

### Minimum Controls for Enterprise MCP Servers

- [ ] Authentication and authorization on all endpoints
- [ ] Audit logging (who accessed what, when)
- [ ] Encryption in transit (TLS 1.2+)
- [ ] Encryption at rest (for stored data)
- [ ] Vulnerability scanning (dependencies and container images)
- [ ] Incident response plan
- [ ] Change management process
- [ ] Access review (periodic review of who has access)
- [ ] Penetration testing (annual or after major changes)

---

## Intellectual Property: Tool Outputs

### Who Owns Tool Outputs?

| Scenario | Output Ownership |
|----------|-----------------|
| Tool transforms user input | Likely the user (they provided the input) |
| Tool returns third-party API data | Third party (subject to their ToS) |
| Tool generates novel content | Depends on jurisdiction and how it was generated |
| Tool returns database query results | Data owner (per data ownership agreements) |
| Tool performs computation | The person who commissioned the computation |

### Key Questions

1. Does your MCP server generate derivative works from copyrighted data?
2. If tools use AI models, who owns the AI-generated output?
3. Do you claim any IP rights over tool results in your ToS?
4. Can users use tool results commercially?

### Recommendations

- Do not claim ownership of tool outputs unless you have a specific reason
- If wrapping an API, pass through the upstream provider's IP terms
- If generating content, clarify ownership in your terms of service
- If your tool creates derivative works, ensure you have rights to the source material

---

## Checklist Summary

Use this as a quick compliance review for any MCP server project.

### Licensing
- [ ] License file included in repository
- [ ] License compatible with all dependencies
- [ ] License appropriate for distribution model (open source vs commercial)

### API Compliance
- [ ] All wrapped API ToS reviewed
- [ ] Rate limits enforced
- [ ] Attribution included where required
- [ ] Commercial use permitted under current API tier

### Privacy
- [ ] Personal data inventory completed
- [ ] Lawful basis documented
- [ ] Retention periods defined
- [ ] Deletion capability implemented
- [ ] Privacy policy published (if public)

### Enterprise (if applicable)
- [ ] SOC 2 controls mapped
- [ ] Audit logging implemented
- [ ] Encryption at rest and in transit
- [ ] Incident response plan documented
