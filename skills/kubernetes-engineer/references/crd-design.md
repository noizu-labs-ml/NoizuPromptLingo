# CRD and Operator Design Guide

Comprehensive reference for designing Kubernetes Custom Resource Definitions and implementing controllers/operators using kubebuilder, controller-runtime, and related tooling.

---

## Table of Contents

1. [API Design Principles](#api-design-principles)
2. [Kubebuilder Scaffolding](#kubebuilder-scaffolding)
3. [CEL Validation Rules](#cel-validation-rules)
4. [Operator Patterns](#operator-patterns)
5. [Versioning and Migration](#versioning-and-migration)
6. [Testing](#testing)
7. [Anti-Patterns](#anti-patterns)

---

## API Design Principles

### Resource Naming

CRD names follow the pattern `<plural>.<group>`. Choose names that will survive schema evolution.

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  # Name MUST be <plural>.<group>
  name: databases.myplatform.io
spec:
  group: myplatform.io
  names:
    kind: Database           # PascalCase — used in YAML apiVersion/kind
    listKind: DatabaseList
    plural: databases        # lowercase plural — used in API paths
    singular: database       # lowercase singular — used in kubectl
    shortNames:
      - db                   # kubectl get db
    categories:
      - myplatform           # kubectl get myplatform (lists all resources in category)
  scope: Namespaced          # or Cluster
```

**Naming guidelines:**
- Group: use a domain you control (`myplatform.io`, `platform.corp.com`)
- Kind: noun, describes one instance (`Database`, not `Databases` or `DatabaseManager`)
- Avoid abbreviations in Kind — use shortNames for CLI convenience
- Reserve `*` in group names for internal use only

### Group Naming

| Pattern | Use Case |
|---------|----------|
| `myplatform.io` | Public-facing platform APIs |
| `internal.myplatform.io` | Internal-only resources (not for users) |
| `alpha.myplatform.io` | Experimental resources, no stability guarantee |
| `k8s.io` | Reserved for upstream Kubernetes |

Group names should reflect the team/domain boundary, not the implementation technology.

### Spec/Status Separation

The fundamental contract: **spec is desired state, status is observed state**.

- Users write to `spec`
- Controllers write to `status` (using the `/status` subresource)
- Never mix intent and observation in one section

```yaml
apiVersion: myplatform.io/v1
kind: Database
metadata:
  name: my-postgres
spec:
  # Desired state — what the user wants
  engine: postgres
  version: "15"
  storage:
    size: 100Gi
    storageClass: openebs-lvmpv
  replicas: 3
  backups:
    enabled: true
    schedule: "0 2 * * *"
status:
  # Observed state — what the controller sees
  phase: Running           # Pending | Provisioning | Running | Degraded | Failed
  readyReplicas: 3
  currentVersion: "15.4"
  connectionSecret: my-postgres-credentials
  conditions:
    - type: Ready
      status: "True"
      lastTransitionTime: "2024-11-15T10:30:00Z"
      reason: AllReplicasReady
      message: "All 3 replicas are ready"
  observedGeneration: 5
```

### Conditions Pattern

Conditions are the standard way to communicate multi-dimensional status. Model them after Kubernetes core conditions.

**Go struct:**

```go
// DatabaseConditionType defines the type of a Database condition
type DatabaseConditionType string

const (
    DatabaseReady        DatabaseConditionType = "Ready"
    DatabaseProvisioned  DatabaseConditionType = "Provisioned"
    DatabaseDegraded     DatabaseConditionType = "Degraded"
    DatabaseBackupReady  DatabaseConditionType = "BackupReady"
)

// DatabaseCondition represents an observation of a Database's state
type DatabaseCondition struct {
    // Type is the type of condition
    Type DatabaseConditionType `json:"type"`

    // Status is one of True, False, Unknown
    Status metav1.ConditionStatus `json:"status"`

    // ObservedGeneration is the .metadata.generation of the resource
    // at the time the condition was set
    // +optional
    ObservedGeneration int64 `json:"observedGeneration,omitempty"`

    // LastTransitionTime is the last time this condition changed
    LastTransitionTime metav1.Time `json:"lastTransitionTime"`

    // Reason is a CamelCase string with no spaces, describing why this
    // condition is in its current state
    Reason string `json:"reason"`

    // Message is a human-readable description of the condition
    // +optional
    Message string `json:"message,omitempty"`
}

// DatabaseStatus defines the observed state of Database
type DatabaseStatus struct {
    Conditions []DatabaseCondition `json:"conditions,omitempty"`

    // ObservedGeneration is the most recent generation observed.
    // When this equals metadata.generation, the controller has processed
    // the latest spec change.
    ObservedGeneration int64 `json:"observedGeneration,omitempty"`

    Phase  DatabasePhase `json:"phase,omitempty"`
    // ... other status fields
}
```

**Condition conventions:**

| Convention | Rule |
|------------|------|
| `Ready` condition | Always present; True = fully operational |
| `status: Unknown` | Use when controller hasn't checked yet |
| `reason` field | CamelCase, no spaces, machine-readable |
| `message` field | Human-readable, may include dynamic values |
| Transitions | Only update `lastTransitionTime` when `status` changes, not on every reconcile |

### ObservedGeneration

`status.observedGeneration` tells users whether the controller has processed the current spec version:

```go
// In reconciler — always update at end of successful reconcile
db.Status.ObservedGeneration = db.Generation
if err := r.Status().Update(ctx, db); err != nil {
    return ctrl.Result{}, err
}
```

Users can `kubectl wait`:
```bash
kubectl wait database/my-postgres \
  --for=jsonpath='{.status.observedGeneration}'=5 \
  --timeout=120s
```

---

## Kubebuilder Scaffolding

### Project Initialization

```bash
# Initialize a new kubebuilder project
kubebuilder init \
  --domain myplatform.io \
  --repo github.com/myorg/database-operator

# Create a new API (CRD + controller)
kubebuilder create api \
  --group platform \
  --version v1alpha1 \
  --kind Database \
  --resource \
  --controller

# Create a webhook (defaulting + validation)
kubebuilder create webhook \
  --group platform \
  --version v1alpha1 \
  --kind Database \
  --defaulting \
  --programmatic-validation
```

### Project Layout

```
.
├── api/
│   └── v1alpha1/
│       ├── database_types.go      # CRD struct definitions
│       ├── database_webhook.go    # Webhook logic (defaulting, validation)
│       └── groupversion_info.go   # Group/version registration
├── config/
│   ├── crd/                       # Generated CRD YAML
│   ├── rbac/                      # Generated RBAC for controller SA
│   ├── manager/                   # Controller Deployment manifests
│   └── webhook/                   # Webhook service + cert config
├── internal/
│   └── controller/
│       ├── database_controller.go # Reconciler implementation
│       └── database_controller_test.go
├── Dockerfile
├── Makefile
└── PROJECT                        # kubebuilder project metadata
```

### Marker Reference

Markers are Go comments that drive code generation (`controller-gen`).

**Type-level markers:**

```go
// +kubebuilder:object:root=true
// +kubebuilder:subresource:status
// +kubebuilder:subresource:scale:specpath=.spec.replicas,statuspath=.status.readyReplicas
// +kubebuilder:printcolumn:name="Phase",type=string,JSONPath=`.status.phase`
// +kubebuilder:printcolumn:name="Ready",type=string,JSONPath=`.status.conditions[?(@.type=='Ready')].status`
// +kubebuilder:printcolumn:name="Age",type=date,JSONPath=`.metadata.creationTimestamp`
// +kubebuilder:resource:shortName=db,categories=myplatform
type Database struct {
    metav1.TypeMeta   `json:",inline"`
    metav1.ObjectMeta `json:"metadata,omitempty"`

    Spec   DatabaseSpec   `json:"spec,omitempty"`
    Status DatabaseStatus `json:"status,omitempty"`
}
```

**Field-level markers:**

```go
type DatabaseSpec struct {
    // Engine is the database engine to use.
    // +kubebuilder:validation:Enum=postgres;mysql;redis
    // +kubebuilder:default=postgres
    Engine string `json:"engine"`

    // Version is the engine version.
    // +kubebuilder:validation:Pattern=`^\d+\.\d+$`
    Version string `json:"version"`

    // Replicas is the number of database replicas.
    // +kubebuilder:validation:Minimum=1
    // +kubebuilder:validation:Maximum=9
    // +kubebuilder:default=1
    // +optional
    Replicas *int32 `json:"replicas,omitempty"`

    // Storage configures persistent storage.
    Storage StorageSpec `json:"storage"`

    // Tags are arbitrary key-value labels.
    // +kubebuilder:validation:MaxProperties=20
    // +optional
    Tags map[string]string `json:"tags,omitempty"`
}
```

**Generate CRD manifests:**

```bash
make generate   # Runs controller-gen object:paths=./...
make manifests  # Runs controller-gen crd rbac webhook
```

---

## CEL Validation Rules

CEL (Common Expression Language) validation runs in the API server without a webhook. Available from Kubernetes 1.25+, stable in 1.29.

### Basic x-kubernetes-validations

```yaml
# In CRD spec.versions[].schema.openAPIV3Schema
properties:
  spec:
    properties:
      replicas:
        type: integer
        minimum: 1
      engine:
        type: string
        enum: [postgres, mysql, redis]
      version:
        type: string
      highAvailability:
        type: boolean
    x-kubernetes-validations:
      # Cross-field validation: HA requires >= 3 replicas
      - rule: "!self.highAvailability || self.replicas >= 3"
        message: "High availability mode requires at least 3 replicas"

      # Conditional requirement: postgres requires version >= 14
      - rule: >
          self.engine != 'postgres' ||
          int(self.version.split('.')[0]) >= 14
        message: "PostgreSQL engine requires version 14 or higher"
```

### Transition Rules (oldSelf vs self)

Transition rules validate the change from old state to new state on updates.

```yaml
x-kubernetes-validations:
  # Immutable field: engine cannot change after creation
  - rule: "self == oldSelf"
    message: "Engine is immutable after creation"
    fieldPath: ".engine"

  # One-way ratchet: version can only increase (no downgrades)
  - rule: >
      !has(oldSelf) ||
      int(self.split('.')[0]) > int(oldSelf.split('.')[0]) ||
      (int(self.split('.')[0]) == int(oldSelf.split('.')[0]) &&
       int(self.split('.')[1]) >= int(oldSelf.split('.')[1]))
    message: "Version downgrade is not permitted"
    fieldPath: ".version"

  # Replicas: only allow scale-down when not in HA mode
  - rule: >
      !has(oldSelf) ||
      self >= oldSelf ||
      !self.highAvailability
    message: "Cannot scale down replicas while in high availability mode"
```

### Cross-Field Validation

```yaml
# At spec level — can reference multiple sibling fields
x-kubernetes-validations:
  - rule: >
      !(self.backups.enabled && !has(self.backups.storageLocation))
    message: "backups.storageLocation is required when backups are enabled"

  - rule: >
      self.resources.requests.memory <= self.resources.limits.memory
    message: "Memory request must not exceed limit"

  # List validation: all tags must have non-empty values
  - rule: >
      self.tags.all(k, self.tags[k] != '')
    message: "Tag values must not be empty"
```

### CEL vs Webhooks Decision Table

| Factor | CEL Validation | Admission Webhook |
|--------|----------------|-------------------|
| Latency | Near-zero (in-process) | Network round-trip |
| Availability risk | None — runs in API server | Webhook outage blocks admission |
| Cross-resource validation | No | Yes |
| External service calls | No | Yes |
| Complex business logic | Limited | Full Go/language power |
| Kubernetes version | 1.25+ (GA 1.29) | All versions |
| Debugging | Limited error messages | Full logging |
| Mutation | No | Yes |

**Decision rule:** Use CEL for field-level and cross-field spec validation. Use webhooks for mutation (defaulting), cross-resource lookups, or external service calls.

### Cost Estimation

CEL validates rule complexity at registration time. Expensive operations can be rejected:

```yaml
# Avoid: O(n^2) or worse on large lists
- rule: "self.items.all(x, self.items.all(y, x.id != y.id))"

# Prefer: bounded complexity
- rule: "self.items.size() <= 100"
- rule: "self.items.map(x, x.id).size() == self.items.size()"  # Uniqueness check — O(n)
```

If a rule is rejected at registration, use a webhook instead.

---

## Operator Patterns

### Level-Triggered Reconciliation

Kubernetes controllers are **level-triggered**, not edge-triggered. The reconciler receives the current state and drives it toward desired state — it does not receive diffs or events.

Consequences:
- The reconciler must be idempotent (running it twice must be safe)
- Do not assume why reconciliation was triggered
- Always read current state from the API server at reconcile time; do not cache in memory
- Use `Result{RequeueAfter: duration}` to poll external resources

### Idempotent Reconciler (Go)

```go
package controller

import (
    "context"
    "fmt"
    "time"

    appsv1 "k8s.io/api/apps/v1"
    corev1 "k8s.io/api/core/v1"
    apierrors "k8s.io/apimachinery/pkg/api/errors"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/apimachinery/pkg/runtime"
    ctrl "sigs.k8s.io/controller-runtime"
    "sigs.k8s.io/controller-runtime/pkg/client"
    "sigs.k8s.io/controller-runtime/pkg/controller/controllerutil"

    platformv1 "github.com/myorg/database-operator/api/v1"
)

const (
    finalizerName = "platform.myplatform.io/database-cleanup"
    requeueDelay  = 30 * time.Second
)

type DatabaseReconciler struct {
    client.Client
    Scheme *runtime.Scheme
}

func (r *DatabaseReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    log := ctrl.LoggerFrom(ctx)

    // 1. Fetch the resource — handle not-found gracefully
    db := &platformv1.Database{}
    if err := r.Get(ctx, req.NamespacedName, db); err != nil {
        if apierrors.IsNotFound(err) {
            // Object deleted — nothing to do
            return ctrl.Result{}, nil
        }
        return ctrl.Result{}, fmt.Errorf("fetching Database: %w", err)
    }

    // 2. Handle deletion
    if !db.DeletionTimestamp.IsZero() {
        return r.handleDeletion(ctx, db)
    }

    // 3. Ensure finalizer is registered
    if !controllerutil.ContainsFinalizer(db, finalizerName) {
        controllerutil.AddFinalizer(db, finalizerName)
        if err := r.Update(ctx, db); err != nil {
            return ctrl.Result{}, fmt.Errorf("adding finalizer: %w", err)
        }
        return ctrl.Result{}, nil  // Requeue after update
    }

    // 4. Reconcile child resources (idempotent creates/updates)
    if err := r.reconcileStatefulSet(ctx, db); err != nil {
        r.setCondition(db, platformv1.DatabaseReady, metav1.ConditionFalse,
            "StatefulSetFailed", err.Error())
        _ = r.Status().Update(ctx, db)
        return ctrl.Result{RequeueAfter: requeueDelay}, err
    }

    if err := r.reconcileService(ctx, db); err != nil {
        return ctrl.Result{RequeueAfter: requeueDelay}, err
    }

    // 5. Check actual state of external/child resources
    ready, err := r.checkReadiness(ctx, db)
    if err != nil {
        return ctrl.Result{RequeueAfter: requeueDelay}, err
    }

    // 6. Update status
    if ready {
        r.setCondition(db, platformv1.DatabaseReady, metav1.ConditionTrue,
            "AllReplicasReady", "Database is fully operational")
        db.Status.Phase = platformv1.DatabasePhaseRunning
    } else {
        r.setCondition(db, platformv1.DatabaseReady, metav1.ConditionFalse,
            "ReplicasNotReady", "Waiting for replicas to become ready")
        db.Status.Phase = platformv1.DatabasePhaseProvisioning
    }

    db.Status.ObservedGeneration = db.Generation

    if err := r.Status().Update(ctx, db); err != nil {
        return ctrl.Result{}, fmt.Errorf("updating status: %w", err)
    }

    log.Info("Reconciled", "phase", db.Status.Phase, "ready", ready)

    if !ready {
        return ctrl.Result{RequeueAfter: 10 * time.Second}, nil
    }
    return ctrl.Result{}, nil
}

// reconcileStatefulSet creates or updates the StatefulSet to match spec.
// Idempotent: safe to call on every reconcile.
func (r *DatabaseReconciler) reconcileStatefulSet(ctx context.Context, db *platformv1.Database) error {
    desired := r.buildStatefulSet(db)

    // Set owner reference so StatefulSet is garbage-collected with Database
    if err := controllerutil.SetControllerReference(db, desired, r.Scheme); err != nil {
        return err
    }

    existing := &appsv1.StatefulSet{}
    err := r.Get(ctx, client.ObjectKeyFromObject(desired), existing)

    if apierrors.IsNotFound(err) {
        return r.Create(ctx, desired)
    }
    if err != nil {
        return fmt.Errorf("getting StatefulSet: %w", err)
    }

    // Patch to desired state (only sends diff)
    patch := client.MergeFrom(existing.DeepCopy())
    existing.Spec = desired.Spec
    return r.Patch(ctx, existing, patch)
}

func (r *DatabaseReconciler) handleDeletion(ctx context.Context, db *platformv1.Database) (ctrl.Result, error) {
    if !controllerutil.ContainsFinalizer(db, finalizerName) {
        return ctrl.Result{}, nil
    }

    // Perform cleanup (e.g., delete external resources, take final backup)
    if err := r.cleanup(ctx, db); err != nil {
        return ctrl.Result{RequeueAfter: requeueDelay}, err
    }

    // Remove finalizer to allow garbage collection
    controllerutil.RemoveFinalizer(db, finalizerName)
    return ctrl.Result{}, r.Update(ctx, db)
}

func (r *DatabaseReconciler) setCondition(db *platformv1.Database, condType platformv1.DatabaseConditionType,
    status metav1.ConditionStatus, reason, message string) {

    now := metav1.Now()
    for i, c := range db.Status.Conditions {
        if c.Type == condType {
            if c.Status != status {
                db.Status.Conditions[i].LastTransitionTime = now
            }
            db.Status.Conditions[i].Status = status
            db.Status.Conditions[i].Reason = reason
            db.Status.Conditions[i].Message = message
            db.Status.Conditions[i].ObservedGeneration = db.Generation
            return
        }
    }
    db.Status.Conditions = append(db.Status.Conditions, platformv1.DatabaseCondition{
        Type:               condType,
        Status:             status,
        LastTransitionTime: now,
        Reason:             reason,
        Message:            message,
        ObservedGeneration: db.Generation,
    })
}

// SetupWithManager registers watches
func (r *DatabaseReconciler) SetupWithManager(mgr ctrl.Manager) error {
    return ctrl.NewControllerManagedBy(mgr).
        For(&platformv1.Database{}).
        Owns(&appsv1.StatefulSet{}).   // Watch owned StatefulSets
        Owns(&corev1.Service{}).       // Watch owned Services
        Complete(r)
}
```

### Finalizers

Finalizers prevent garbage collection until the controller completes cleanup. Register early, remove only after cleanup succeeds.

```go
// Register on first reconcile
controllerutil.AddFinalizer(obj, "myplatform.io/cleanup")
r.Update(ctx, obj)

// Remove after cleanup completes
controllerutil.RemoveFinalizer(obj, "myplatform.io/cleanup")
r.Update(ctx, obj)
```

Never block indefinitely in cleanup — use exponential backoff via `RequeueAfter`.

### Owner References

Owner references establish parent-child relationships. Child objects are garbage-collected when the parent is deleted.

```go
// SetControllerReference adds owner ref and sets controller=true
// Only one owner can have controller=true
controllerutil.SetControllerReference(parent, child, r.Scheme)

// SetOwnerReference adds owner ref without controller=true
// Use for cross-namespace or multiple owners (note: cross-namespace is blocked by K8s)
controllerutil.SetOwnerReference(parent, child, r.Scheme)
```

**Cross-namespace ownership is not supported** — use finalizers instead.

### Event Recording

Emit Events to give users visibility into what the controller is doing:

```go
// In controller struct
type DatabaseReconciler struct {
    client.Client
    Scheme   *runtime.Scheme
    Recorder record.EventRecorder
}

// In SetupWithManager
r.Recorder = mgr.GetEventRecorderFor("database-controller")

// In reconciler
r.Recorder.Event(db, corev1.EventTypeNormal, "Provisioning", "Creating StatefulSet")
r.Recorder.Eventf(db, corev1.EventTypeWarning, "BackupFailed",
    "Backup to %s failed: %v", db.Spec.Backups.StorageLocation, err)
```

---

## Versioning and Migration

### v1alpha1 → v1 Lifecycle

| Stage | Stability Contract |
|-------|-------------------|
| `v1alpha1` | No stability; can break at any time |
| `v1beta1` | No breaking changes within minor releases; 9-month deprecation window |
| `v1` | Full stability; no breaking changes; 12-month deprecation minimum |

Promote a version by:
1. Adding the new version to `spec.versions[]` in the CRD
2. Implementing a conversion webhook (hub-and-spoke pattern)
3. Setting `storage: true` on the new version, `storage: false` on old
4. Marking old version `deprecated: true` (shows warning in kubectl)

```yaml
spec:
  versions:
    - name: v1
      served: true
      storage: true    # New storage version
      schema: ...
    - name: v1alpha1
      served: true     # Still served for migration period
      storage: false
      deprecated: true
      deprecationWarning: "v1alpha1 is deprecated; migrate to v1"
      schema: ...
  conversion:
    strategy: Webhook
    webhook:
      conversionReviewVersions: ["v1"]
      clientConfig:
        service:
          name: database-operator-webhook-service
          namespace: database-operator-system
          path: /convert
```

### Conversion Webhooks (Hub and Spoke)

The hub version is the internal representation. All other versions convert to/from hub.

```go
// api/v1/database_conversion.go
// v1 is the hub — no conversion needed
func (*Database) Hub() {}

// api/v1alpha1/database_conversion.go
// v1alpha1 converts to/from v1 (hub)

func (src *Database) ConvertTo(dstRaw conversion.Hub) error {
    dst := dstRaw.(*v1.Database)

    // Spec conversion
    dst.Spec.Engine = src.Spec.Engine
    dst.Spec.Version = src.Spec.Version
    dst.Spec.Replicas = src.Spec.Replicas

    // Handle field additions: new field in v1 that didn't exist in v1alpha1
    if dst.Spec.Replicas == nil {
        one := int32(1)
        dst.Spec.Replicas = &one
    }

    // Preserve unknown fields via annotations
    dst.ObjectMeta = src.ObjectMeta
    return nil
}

func (dst *Database) ConvertFrom(srcRaw conversion.Hub) error {
    src := srcRaw.(*v1.Database)

    dst.Spec.Engine = src.Spec.Engine
    dst.Spec.Version = src.Spec.Version
    dst.Spec.Replicas = src.Spec.Replicas
    dst.ObjectMeta = src.ObjectMeta
    return nil
}
```

**Register webhook server:**

```go
// In main.go
if err := (&platformv1alpha1.Database{}).SetupWebhookWithManager(mgr); err != nil {
    setupLog.Error(err, "unable to create conversion webhook")
    os.Exit(1)
}
```

---

## Testing

### envtest (Integration Tests)

`envtest` runs a real API server and etcd locally without a full cluster:

```go
package controller_test

import (
    "context"
    "path/filepath"
    "testing"

    . "github.com/onsi/ginkgo/v2"
    . "github.com/onsi/gomega"
    "k8s.io/client-go/kubernetes/scheme"
    ctrl "sigs.k8s.io/controller-runtime"
    "sigs.k8s.io/controller-runtime/pkg/client"
    "sigs.k8s.io/controller-runtime/pkg/envtest"

    platformv1 "github.com/myorg/database-operator/api/v1"
)

var (
    k8sClient client.Client
    testEnv   *envtest.Environment
    ctx       context.Context
    cancel    context.CancelFunc
)

func TestControllers(t *testing.T) {
    RegisterFailHandler(Fail)
    RunSpecs(t, "Controller Suite")
}

var _ = BeforeSuite(func() {
    ctx, cancel = context.WithCancel(context.TODO())

    testEnv = &envtest.Environment{
        CRDDirectoryPaths: []string{
            filepath.Join("..", "..", "config", "crd", "bases"),
        },
    }

    cfg, err := testEnv.Start()
    Expect(err).NotTo(HaveOccurred())

    err = platformv1.AddToScheme(scheme.Scheme)
    Expect(err).NotTo(HaveOccurred())

    k8sClient, err = client.New(cfg, client.Options{Scheme: scheme.Scheme})
    Expect(err).NotTo(HaveOccurred())

    mgr, err := ctrl.NewManager(cfg, ctrl.Options{Scheme: scheme.Scheme})
    Expect(err).NotTo(HaveOccurred())

    err = (&DatabaseReconciler{
        Client: mgr.GetClient(),
        Scheme: mgr.GetScheme(),
    }).SetupWithManager(mgr)
    Expect(err).NotTo(HaveOccurred())

    go func() {
        defer GinkgoRecover()
        err = mgr.Start(ctx)
        Expect(err).NotTo(HaveOccurred())
    }()
})

var _ = AfterSuite(func() {
    cancel()
    Expect(testEnv.Stop()).To(Succeed())
})

var _ = Describe("Database Controller", func() {
    It("should create a StatefulSet when a Database is created", func() {
        db := &platformv1.Database{
            ObjectMeta: metav1.ObjectMeta{
                Name:      "test-db",
                Namespace: "default",
            },
            Spec: platformv1.DatabaseSpec{
                Engine:   "postgres",
                Version:  "15",
                Replicas: pointer.Int32(1),
            },
        }
        Expect(k8sClient.Create(ctx, db)).To(Succeed())

        sts := &appsv1.StatefulSet{}
        Eventually(func() error {
            return k8sClient.Get(ctx, types.NamespacedName{
                Name: "test-db", Namespace: "default",
            }, sts)
        }, 10*time.Second, 250*time.Millisecond).Should(Succeed())

        Expect(*sts.Spec.Replicas).To(Equal(int32(1)))
    })
})
```

### Fake Client (Unit Tests)

For testing reconciler logic without envtest overhead:

```go
func TestReconcile_CreateStatefulSet(t *testing.T) {
    scheme := runtime.NewScheme()
    _ = platformv1.AddToScheme(scheme)
    _ = appsv1.AddToScheme(scheme)

    db := &platformv1.Database{
        ObjectMeta: metav1.ObjectMeta{
            Name:      "test-db",
            Namespace: "default",
        },
        Spec: platformv1.DatabaseSpec{
            Engine:  "postgres",
            Version: "15",
        },
    }

    fakeClient := fake.NewClientBuilder().
        WithScheme(scheme).
        WithObjects(db).
        WithStatusSubresource(db).
        Build()

    r := &DatabaseReconciler{
        Client: fakeClient,
        Scheme: scheme,
    }

    result, err := r.Reconcile(context.TODO(), ctrl.Request{
        NamespacedName: types.NamespacedName{
            Name: "test-db", Namespace: "default",
        },
    })

    assert.NoError(t, err)
    assert.Equal(t, ctrl.Result{}, result)

    sts := &appsv1.StatefulSet{}
    err = fakeClient.Get(context.TODO(), types.NamespacedName{
        Name: "test-db", Namespace: "default",
    }, sts)
    assert.NoError(t, err)
}
```

### E2E Testing with kind

```bash
# Create local cluster
kind create cluster --name operator-e2e --config kind-config.yaml

# Install CRDs
kubectl apply -f config/crd/bases/

# Deploy operator
make deploy IMG=myorg/database-operator:dev

# Run e2e tests
go test ./test/e2e/... -v -timeout 10m

# Cleanup
kind delete cluster --name operator-e2e
```

```yaml
# kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

---

## Anti-Patterns

### Storing Large Data in CRDs

**Problem:** CRD objects are stored in etcd and have a 1.5 MB size limit per object. Storing large blobs (logs, rendered configs, large schemas) in status will hit this limit.

**Fix:** Store large data in ConfigMaps, external storage (S3, database), or use references:

```yaml
# Bad — storing large output in status
status:
  lastMigrationOutput: "<10,000 lines of SQL output>"

# Good — reference to where data is stored
status:
  lastMigrationOutputRef:
    configMapName: my-db-migration-2024-11-15
    key: output
```

### Dual Operators Managing the Same Resource

**Problem:** Two controllers both watch and mutate the same resource type. They will fight each other, causing oscillation.

**Fix:** One resource type, one controller. Use `Owns()` to delegate child resource management within one operator. Coordinate via status conditions or separate CRD kinds for separate domains.

### Non-Idempotent Reconciliation

**Problem:** Reconciler that creates resources without checking if they exist first; or that fires external side effects unconditionally.

```go
// Bad: creates duplicate on every reconcile
r.Create(ctx, desired)  // Returns AlreadyExists error — but damage may be done

// Bad: sends notification email every reconcile
sendEmail("Database provisioned")

// Good: check first
existing := &appsv1.StatefulSet{}
err := r.Get(ctx, client.ObjectKeyFromObject(desired), existing)
if apierrors.IsNotFound(err) {
    return r.Create(ctx, desired)
}
```

For side effects (notifications, webhooks, billing), track whether the action was taken in `.status`, and only fire if status doesn't record it yet.

### Caching State in Controller Memory

**Problem:** Storing derived state in controller struct fields. This state is lost on restart and diverges under concurrent reconciles.

```go
// Bad
type MyReconciler struct {
    client.Client
    provisionedDBs map[string]bool  // Lost on restart!
}

// Good — read from API server every time
db := &platformv1.Database{}
r.Get(ctx, req.NamespacedName, db)
// db.Status.Phase is the source of truth
```

### Blocking Reconcile Loop

**Problem:** Reconciler performs long-running operations synchronously, blocking the goroutine and starving other resources.

```go
// Bad: blocks reconciler for minutes
waitForDatabaseToBeReady(db)  // Polling loop inside reconciler

// Good: return and let controller requeue
ready, err := r.checkReadiness(ctx, db)
if !ready {
    return ctrl.Result{RequeueAfter: 10 * time.Second}, nil
}
```

### Missing Status Subresource

**Problem:** Status updated via the main object endpoint. This means spec+status are in the same resource version, and a spec update racing with a status update will cause one to overwrite the other.

**Fix:** Always declare `+kubebuilder:subresource:status` and use `r.Status().Update()` for status updates. Never update status via `r.Update()`.

```go
// Bad: races with spec updates
r.Update(ctx, db)

// Good: separate subresource
r.Status().Update(ctx, db)
// or
r.Status().Patch(ctx, db, patch)
```
