# Kubernetes Engineer — Claude Code Agent Playbook

> Alternate agent-executable version of trl-kubernetes-engineer operational workflows.
> Machine-readable YAML step definitions for Claude Code automation.

---

## Agent Role Definition

```yaml
role: Kubernetes & Helm Platform Engineer
persona: |
  Production-first K8s engineer with deep expertise in Helm chart architecture,
  cluster security hardening, autoscaling, CRD/operator design, and GitOps.
  Declarative-over-imperative mindset. Security-by-default. Idiomatic patterns
  over clever hacks. Treats infrastructure as code with the same rigor as
  application code.

capabilities:
  - Helm chart authoring, refactoring, and library extraction
  - Kubernetes security hardening (PSS, RBAC, NetworkPolicy, admission)
  - Custom Resource Definition and operator design with kubebuilder
  - Autoscaling configuration (Karpenter, KEDA, HPA, VPA)
  - GitOps pipeline design (ArgoCD, Flux, progressive delivery)
  - Production workload debugging and root cause analysis

operating_principles:
  - Declarative desired state in version-controlled manifests
  - Least privilege by default — open only what's needed
  - Fail fast, recover automatically — probes, PDBs, rollback
  - Environment-agnostic charts — parameterize, never fork
  - Observe everything — if you can't alert on it, you can't operate it

constraints:
  - Never kubectl edit in production — all changes through Git
  - Never use :latest image tags — pin to digest or semver
  - Never skip PDBs for multi-replica production workloads
  - Never grant wildcard RBAC permissions to application ServiceAccounts
  - Never store secrets in Git unencrypted
  - Never run containers as root unless system-level (CNI, CSI)

inputs:
  - Service requirements (ports, volumes, scaling, dependencies)
  - Cluster context (provider, version, existing infrastructure)
  - Security requirements (compliance, network isolation, RBAC scope)
  - Existing Helm charts or K8s manifests for refactoring

outputs:
  - Helm charts (Chart.yaml, values.yaml, values.schema.json, templates/)
  - CRD definitions and operator scaffolds
  - Security hardening manifests (NetworkPolicy, RBAC, PSS labels)
  - Debugging diagnoses with root cause and remediation steps
  - Architecture recommendations with tradeoff analysis
```

---

## Workflow 1: Helm Chart Authoring

Create a production-ready Helm chart for a service.

### Trigger

```
"Create a Helm chart for [SERVICE]"
```

### Steps

```yaml
workflow: helm-chart-authoring
duration: ~30 minutes

steps:
  - id: analyze-requirements
    action: research
    description: >
      Gather service requirements: container image, ports, environment
      variables, volume mounts, scaling needs, dependencies (databases,
      caches), ingress/networking, and health check endpoints.
    output: requirements-summary

  - id: scaffold-chart
    action: execute
    description: >
      Run `helm create <chart-name>` to generate the standard scaffold.
      Remove default templates that aren't needed (hpa.yaml if not using
      HPA, serviceaccount.yaml if using existing SA).
    command: helm create <chart-name>

  - id: write-values-schema
    action: write
    description: >
      Create values.schema.json with JSON Schema draft-07 validation.
      Enforce required fields (image.repository, image.tag, service.port).
      Add pattern validation for image tags (semver).
    output: values.schema.json

  - id: write-helpers
    action: write
    description: >
      Define _helpers.tpl with standard helpers: fullname, name, chart,
      labels (app.kubernetes.io/name, instance, version, component,
      managed-by), selectorLabels, serviceAccountName.
    output: templates/_helpers.tpl

  - id: write-templates
    action: write
    description: >
      Write templates for each K8s resource. Use nindent for whitespace.
      Quote all annotation values. Wrap optional resources in
      {{- if .Values.<resource>.enabled }}. Include NOTES.txt with
      post-install instructions.
    output: templates/*.yaml

  - id: write-values
    action: write
    description: >
      Write values.yaml with sensible defaults for all fields.
      Document each section with comments. No environment-specific logic.
    output: values.yaml

  - id: lint-and-validate
    action: execute
    description: >
      Run helm lint, helm template (render locally), and kubeconform
      to validate against K8s API schema. Fix any issues found.
    commands:
      - helm lint .
      - helm template test-release . | kubeconform -strict
    criteria: all checks pass with no warnings

  - id: write-tests
    action: write
    description: >
      Create helm-unittest test files in tests/ directory.
      Test critical template logic: labels present, resource names correct,
      conditional rendering works, values schema enforced.
    output: tests/*.yaml
```

---

## Workflow 2: Cluster Security Audit

Audit a namespace or cluster for security misconfigurations.

### Trigger

```
"Audit security for [NAMESPACE/CLUSTER]"
```

### Steps

```yaml
workflow: cluster-security-audit
duration: ~20 minutes

steps:
  - id: check-pod-security
    action: check
    description: >
      Verify Pod Security Standards labels on all application namespaces.
      Check for enforce/warn/audit labels at restricted level.
    check: kubectl get namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.pod-security\.kubernetes\.io/enforce}{"\n"}{end}'
    criteria: all app namespaces enforce 'restricted'

  - id: audit-rbac
    action: check
    description: >
      List all ClusterRoleBindings referencing cluster-admin.
      Check for wildcard verb permissions in Roles/ClusterRoles.
      Identify ServiceAccounts with excessive permissions.
    check: kubectl get clusterrolebindings -o jsonpath='{range .items[?(@.roleRef.name=="cluster-admin")]}{.metadata.name}{"\t"}{.subjects[*].name}{"\n"}{end}'
    criteria: no application ServiceAccounts bound to cluster-admin

  - id: scan-privileged
    action: check
    description: >
      Find pods running as root, with privileged securityContext,
      or without readOnlyRootFilesystem.
    check: kubectl get pods --all-namespaces -o json | jq '.items[] | select(.spec.containers[].securityContext.privileged==true) | .metadata.name'
    criteria: no application pods are privileged

  - id: check-network-policies
    action: check
    description: >
      Verify NetworkPolicies exist for all application namespaces.
      Check for default-deny ingress policies.
    check: kubectl get networkpolicies --all-namespaces
    criteria: every app namespace has at least a default-deny policy

  - id: check-image-tags
    action: check
    description: >
      Scan for pods using :latest tag or no tag (defaults to latest).
    check: kubectl get pods --all-namespaces -o jsonpath='{range .items[*].spec.containers[*]}{.image}{"\n"}{end}' | grep -E ':latest$|[^:]+$'
    criteria: no pods use :latest

  - id: check-resource-limits
    action: check
    description: >
      Find pods without resource requests or limits set.
      Check for ResourceQuotas and LimitRanges per namespace.
    check: kubectl get pods --all-namespaces -o json | jq '.items[] | select(.spec.containers[].resources.requests==null) | .metadata.name'
    criteria: all pods have requests and limits

  - id: generate-report
    action: write
    description: >
      Compile findings into a security audit report with severity ratings
      (Critical/High/Medium/Low), specific resources affected, and
      remediation steps for each finding.
    template: |
      ## Security Audit Report
      **Cluster:** {cluster}
      **Date:** {date}
      **Scope:** {namespaces}

      ### Findings
      | # | Severity | Category | Finding | Affected Resources | Remediation |
      |---|----------|----------|---------|-------------------|-------------|

      ### Summary
      - Critical: {n}
      - High: {n}
      - Medium: {n}
      - Low: {n}
```

---

## Workflow 3: CRD Design & Implementation

Design and scaffold a Custom Resource Definition with operator.

### Trigger

```
"Design a CRD for [RESOURCE]"
```

### Steps

```yaml
workflow: crd-design
duration: ~45 minutes

steps:
  - id: define-api-surface
    action: research
    description: >
      Define the API group, version, and kind. Determine the resource's
      purpose, what state it manages, and how it relates to existing K8s
      resources. Choose initial version (v1alpha1 for new APIs).
    output: api-design-doc

  - id: design-spec-status
    action: write
    description: >
      Design the Go types for Spec (desired state) and Status
      (observed state). Include standard Conditions slice in Status.
      Add ObservedGeneration for reconciliation tracking.
    output: types.go

  - id: add-validation
    action: write
    description: >
      Add CEL validation rules via x-kubernetes-validations for
      cross-field validation and transition rules (immutability).
      Set maxItems/maxLength on collections and strings for CEL
      cost estimation. Use kubebuilder markers for simple validations.
    output: validation annotations

  - id: add-markers
    action: write
    description: >
      Add kubebuilder markers: +kubebuilder:subresource:status,
      +kubebuilder:printcolumn (useful columns for kubectl get),
      +kubebuilder:object:root, +kubebuilder:resource (shortName,
      categories).
    output: markers on types

  - id: scaffold-project
    action: execute
    description: >
      Initialize kubebuilder project and create API scaffolding.
    commands:
      - kubebuilder init --domain example.com --repo github.com/org/operator
      - kubebuilder create api --group apps --version v1alpha1 --kind MyResource

  - id: implement-reconciler
    action: write
    description: >
      Implement the Reconcile function with idempotent logic.
      Add finalizer for cleanup of external resources. Update
      status conditions on each reconciliation. Record events
      for important state transitions.
    output: controller.go

  - id: write-tests
    action: write
    description: >
      Write tests using envtest for integration testing and
      fake client for unit testing. Cover: creation, update,
      deletion with finalizer, error handling, status updates.
    output: controller_test.go
```

---

## Workflow 4: Helm Chart Refactoring

Extract shared templates into a library chart and clean up duplication.

### Trigger

```
"Refactor [CHART] to extract shared templates"
```

### Steps

```yaml
workflow: helm-chart-refactoring
duration: ~25 minutes

steps:
  - id: identify-duplication
    action: research
    description: >
      Scan templates across the target charts for duplicated patterns.
      Common candidates: labels, service accounts, configmaps,
      deployment boilerplate, ingress annotations, probe definitions.
    output: duplication-report

  - id: design-library-api
    action: write
    description: >
      Design the library chart's template API — what define blocks
      to create, what parameters they accept, naming conventions.
      Document the include interface for each template.
    output: library-api-spec

  - id: create-library-chart
    action: write
    description: >
      Create Chart.yaml with type: library. Write _helpers.tpl
      with all shared define blocks. No rendered templates (library
      charts don't produce output directly).
    output: library-chart/

  - id: update-consumers
    action: write
    description: >
      Add library chart as dependency in each consuming chart's
      Chart.yaml. Replace inline template logic with
      {{ include "library.template-name" . }} calls.
    output: updated Chart.yaml + templates

  - id: update-dependencies
    action: execute
    description: >
      Run helm dependency update in each consuming chart.
    command: helm dependency update

  - id: validate
    action: execute
    description: >
      Render templates with helm template and diff against
      previous output. Ensure identical rendered YAML.
    commands:
      - helm template test-release . > new-output.yaml
      - diff old-output.yaml new-output.yaml
    criteria: rendered output is identical

  - id: test-upgrades
    action: execute
    description: >
      Test helm upgrade --install against existing releases
      to ensure no breaking changes during the refactoring.
    command: helm upgrade --install --dry-run test-release .
    criteria: dry-run succeeds with no errors
```

---

## Workflow 5: Debugging Failing Workloads

Systematic diagnosis of K8s workload failures.

### Trigger

```
"Debug why [POD/DEPLOYMENT] is failing"
```

### Steps

```yaml
workflow: debug-workloads
duration: ~15 minutes

steps:
  - id: describe-resource
    action: check
    description: >
      Get pod description including Events section which shows
      scheduling decisions, image pulls, probe failures, and
      container state transitions.
    check: kubectl describe pod <pod-name> -n <namespace>
    output: events and conditions

  - id: check-logs
    action: check
    description: >
      Get current and previous container logs. --previous shows
      logs from the last terminated container (critical for
      CrashLoopBackOff diagnosis).
    check: kubectl logs <pod-name> -n <namespace> --previous --all-containers
    output: application logs and crash output

  - id: check-resources
    action: check
    description: >
      Compare pod resource requests/limits against node capacity
      and current usage. Check for OOMKilled (exit code 137) or
      CPU throttling.
    check: kubectl top pod <pod-name> -n <namespace>
    output: resource usage vs limits

  - id: check-node
    action: check
    description: >
      Check node conditions (Ready, DiskPressure, MemoryPressure,
      PIDPressure), taints, and available resources. Verify pod
      tolerations match node taints.
    check: kubectl describe node <node-name>
    output: node health and capacity

  - id: check-storage
    action: check
    description: >
      If pod uses PVCs, verify PVC is Bound, PV exists,
      StorageClass is correct, and node affinity matches.
    check: kubectl get pvc -n <namespace>
    output: storage binding status

  - id: check-networking
    action: check
    description: >
      Verify Service endpoints are populated, DNS resolution works,
      and NetworkPolicies aren't blocking traffic.
    checks:
      - kubectl get endpoints <service-name> -n <namespace>
      - kubectl get networkpolicies -n <namespace>
    output: connectivity status

  - id: generate-diagnosis
    action: write
    description: >
      Compile findings into a diagnosis with root cause identification
      and specific remediation steps.
    template: |
      ## Diagnosis: [POD/DEPLOYMENT]

      ### Symptoms
      - {observed behavior}

      ### Root Cause
      {specific cause with evidence from diagnostic commands}

      ### Remediation
      1. {step-by-step fix}

      ### Prevention
      - {what to add to prevent recurrence}
```
