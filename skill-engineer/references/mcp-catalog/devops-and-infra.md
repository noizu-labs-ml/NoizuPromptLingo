# Category: DevOps and Infrastructure

## Overview
Use tools in this category when a skill needs to inspect, provision, deploy, or manage infrastructure components — either cloud resources, container runtimes, or IaC state. The critical design constraint for all infra tools is the **human-approval boundary**: read and plan operations are generally safe for autonomous agent execution; apply, destroy, and restart operations must require explicit human confirmation. Skill designers should encode this boundary explicitly in workflow steps, not rely on the MCP server to enforce it.

## MCP Services

| Name | Deployment | Key Features | Security Notes | Maturity |
|------|-----------|-------------|----------------|----------|
| Docker MCP | Local stdio | Container health, image inspection, runtime stats | Docker socket access = root equivalent | Stable |
| Kubernetes MCP | Local stdio | Pod management, namespace ops, OpenShift compat | kubeconfig determines cluster scope | Stable |
| Lens MCP | Hosted / local | AWS EKS + Azure AKS, no kubeconfig needed | Cloud provider credentials required | Beta |
| Terraform MCP | Local stdio | Registry queries, workspace state, human approval gate | State file contains secrets | Stable |
| Pulumi MCP | Hosted + local | Org registry, command execution, stack management | Pulumi access token required | Beta |
| AWS MCP | Managed remote (AWS) | Lambda/ECS/EKS/S3/EC2/RDS, FinOps, managed remote | AWS IAM controls all access | Stable |
| Cloudflare MCP | Hosted SSE | Workers, KV, DNS, edge compute, R2 | Cloudflare API token scoping critical | Stable |

---

### Terraform MCP
- **What it does**: MCP server for HashiCorp Terraform that exposes registry module and provider queries, workspace state inspection, plan output reading, and apply execution (with configurable human-approval gate). Allows AI agents to understand IaC intent and current state before proposing or executing infrastructure changes.
- **Deployment**: Local stdio via `npx @hashicorp/terraform-mcp-server` or Docker; connects to local Terraform CLI and state backend (local files, S3, Terraform Cloud, HCP Terraform); optionally connects to HCP Terraform API for remote workspace management
- **Key features**: Terraform Registry queries (search modules, read provider docs, pin versions); `terraform show` state inspection as structured JSON; `terraform plan` output parsing (resources to add/change/destroy); `terraform apply` execution with human-approval checkpoint before destructive operations; workspace listing and switching; variable file reading; module dependency graph; provider schema introspection for LLM-assisted configuration writing
- **Security considerations**: Terraform state files contain secrets (database passwords, API keys, private keys) in plaintext. Never log or display raw state output. The MCP server reads state via `terraform show` — ensure the agent is not echoing state to logs. Apply operations are irreversible for some resources (IAM roles, VPCs, databases) — the human-approval gate must be enforced at the skill workflow level, not assumed from the MCP server. Backend credentials (S3, HCP) must be available in the environment; do not embed them in MCP config files committed to git.
- **When to use**: Skills that scaffold new infrastructure from templates (generate Terraform modules, validate with `plan`, require human approval before `apply`); IaC audit workflows (read current state, identify drift, surface unused resources); skills that help developers understand existing Terraform configurations by querying the registry for module docs; FinOps skills that analyze resource cost estimates from plan output.
- **When to avoid**: When Pulumi is the IaC tool (use Pulumi MCP); when the user's infra is managed entirely via cloud consoles with no IaC (no state to read); when the agent needs to apply changes without any human checkpoint (never appropriate for production infra).

---

### AWS MCP
- **What it does**: Suite of AWS-managed MCP servers (one per service family) that expose AWS API operations as MCP tool calls. Available as a fully managed remote endpoint hosted by AWS, eliminating the need to run local MCP server processes. Covers Lambda, ECS, EKS, S3, EC2, RDS, CloudFormation, and cost/billing (FinOps).
- **Deployment**: Managed remote (AWS hosts the MCP endpoint); authenticated via AWS IAM credentials (access key + secret, or role-based via AWS SSO/IAM Identity Center); no local install required; connect via MCP client config pointing to the AWS-managed endpoint URL
- **Key features**: Lambda: list functions, get code, invoke (with approval gate), view logs; ECS: list clusters/services/tasks, describe task definitions, update service (with approval); EKS: cluster listing, kubeconfig generation, node group management; S3: bucket listing, object enumeration, presigned URL generation; EC2: instance listing, security group inspection, AMI queries; RDS: instance listing, parameter group inspection, snapshot management; CloudFormation: stack listing, resource enumeration, drift detection; FinOps: cost explorer queries, resource cost attribution, savings plan analysis; managed remote means AWS handles TLS, auth, and server maintenance
- **Security considerations**: IAM is the entire security model — the MCP server can only do what the IAM principal's policies allow. Follow least-privilege: create a dedicated IAM user or role for the MCP connection with only the permissions the skill needs. Avoid using AdministratorAccess. Managed remote endpoint means AWS handles the MCP server process — trust model is the same as AWS CLI access. Never log IAM credentials. For production accounts, prefer IAM roles via SSO over long-lived access keys.
- **When to use**: Cloud-native skills that need to inspect or manage AWS resources (cost audits, deployment automation, log analysis, resource inventory); any workflow where the user already has AWS credentials configured and wants an agent to read or act on AWS state; FinOps skills for cost optimization; deployment skills that invoke Lambda or update ECS services after CI passes.
- **When to avoid**: Non-AWS cloud environments (use equivalent GCP or Azure MCPs); when all infra is managed via Terraform and direct AWS API calls would create drift (use Terraform MCP to read state instead, apply via Terraform); when the required IAM permissions cannot be scoped tightly enough for the risk tolerance of the workflow.

---

### Kubernetes MCP
- **What it does**: MCP server for Kubernetes cluster management exposing pod, deployment, service, namespace, configmap, and secret operations as tool calls. Compatible with standard Kubernetes clusters and OpenShift. Uses the active kubeconfig context to determine cluster and namespace scope.
- **Deployment**: Local stdio; `npx @kubernetes/mcp-server` or Docker; reads `~/.kube/config` or `KUBECONFIG` env var; cluster context is set before invoking the MCP server (agent should not switch contexts autonomously)
- **Key features**: Pod listing, describe, log streaming, and exec (with approval gate for exec); Deployment listing, describe, scale, and rollout status; Service and Ingress inspection; Namespace management; ConfigMap and Secret listing (Secret values redacted by default); Event streaming (surface CrashLoopBackOff, OOMKilled, etc.); `kubectl apply` equivalent for manifest application (with approval gate); resource quota and limit range inspection; OpenShift route and DeploymentConfig support; Lens MCP alternative for managed Kubernetes (EKS, AKS) without kubeconfig
- **Security considerations**: kubeconfig context determines everything — if the context points to production, the agent has production access. Always verify active context before invoking the MCP server. Secret values should be redacted in agent responses; the MCP server redacts by default but verify this for your implementation. `kubectl exec` into pods is equivalent to shell access on the node — gate behind human approval. RBAC on the cluster limits what the MCP server can do; create a dedicated ServiceAccount with minimal permissions for the MCP connection.
- **When to use**: Skills that inspect cluster health (pod status, event analysis, resource utilization); deployment automation skills (apply manifests, watch rollout, roll back on failure); log analysis workflows (stream pod logs, correlate with events); skills that scaffold Kubernetes manifests and validate them against a real cluster before committing; OpenShift-specific workflows.
- **When to avoid**: When the cluster is EKS or AKS and kubeconfig management is the pain point (use Lens MCP for cloud-managed clusters without kubeconfig); when all Kubernetes resources are managed via Terraform Helm provider (use Terraform MCP for state, avoid direct kubectl API calls that bypass IaC); when the agent needs to execute arbitrary commands in pods autonomously (security boundary too broad).

---

## CLI Tools

| Name | Install | What It Does | Skill Relevance |
|------|---------|-------------|-----------------|
| `terraform` | Hashicorp releases | IaC plan/apply/state management | Infrastructure provisioning |
| `kubectl` | OS package manager | Kubernetes cluster management | Pod/deployment operations |
| `aws` | `pip install awscli` | AWS API via CLI | Resource inspection + automation |
| `docker` | Docker Desktop / engine | Container build, run, inspect | Local container workflows |
| `helm` | Homebrew / binary | Kubernetes package manager | Chart-based deployments |
| `pulumi` | Brew / npm | IaC with TypeScript/Python/Go | Pulumi stack management |
| `cloudflare` | `npm i -g wrangler` | Cloudflare Workers deploy + KV | Edge compute deployment |

---

## Selection Guide

**Choose by infra layer:**

| Layer | Best Choice | Fallback |
|-------|------------|---------|
| AWS cloud resources | AWS MCP | Terraform MCP (if IaC-managed) |
| Kubernetes workloads | Kubernetes MCP | Lens MCP (EKS/AKS) |
| IaC state + planning | Terraform MCP | Pulumi MCP |
| Container runtime (local) | Docker MCP | Docker CLI |
| Edge compute (Cloudflare) | Cloudflare MCP | Wrangler CLI |
| Cloud-managed K8s (no kubeconfig) | Lens MCP | Kubernetes MCP + kubeconfig setup |

**Human-approval boundaries (always enforce):**

| Operation | Approval Required? |
|-----------|-------------------|
| `terraform plan` | No — read-only |
| `terraform apply` | Yes — always |
| `kubectl get / describe / logs` | No — read-only |
| `kubectl apply / delete` | Yes — always |
| `kubectl exec` | Yes — always |
| `aws s3 ls` / `ec2 describe` | No — read-only |
| `aws lambda invoke` (production) | Yes — always |
| Docker `inspect` / `ps` | No — read-only |
| Docker `stop` / `rm` | Yes — if production |

**Data residency:**
- All local → Docker MCP, Kubernetes MCP (local cluster), Terraform MCP (local state)
- AWS-managed remote → AWS MCP
- Cloud SaaS → Lens MCP, Cloudflare MCP, Pulumi MCP (hosted)

**IaC consistency rule:**
If infrastructure is managed by Terraform or Pulumi, prefer reading state via those MCPs over making direct AWS/K8s API calls. Direct API calls bypass IaC and cause drift.
