# Writing Custom Terraform Providers

Custom Terraform providers extend Terraform's ability to manage infrastructure by implementing CRUD operations against any API. This guide covers architecture, implementation with the Plugin Framework, testing, debugging, publishing, and alternative approaches.

---

## When to Write a Custom Provider

**Write a custom provider when:**

- **Your organization has an internal API with no existing provider.** Internal platforms, proprietary systems, and bespoke infrastructure tools are the primary use case. If your team manages resources through a REST or gRPC API that Terraform cannot reach, a custom provider bridges that gap.

- **You need to manage resources in a niche system.** Smaller SaaS platforms, legacy systems, or domain-specific tools often lack community providers. Check the [Terraform Registry](https://registry.terraform.io/) first — there are 4,800+ providers as of 2026.

- **An existing provider lacks resources you need.** Before writing a new provider, contribute upstream. Open an issue, submit a PR. Most major providers (AWS, GCP, Azure) accept community contributions. Only fork or create a new provider when upstream contribution is impractical (abandoned project, philosophical disagreement on scope, internal-only resource types).

**Do NOT write a custom provider when:**

- A `local-exec` provisioner or `external` data source suffices for a one-off operation
- The `restapi` or `http` provider can handle your use case with generic REST calls
- You only need to read data — a shell script called via `external` may be simpler

---

## Architecture Overview

### How Terraform Communicates with Providers

Terraform uses **gRPC over a local socket** to communicate with providers. Each provider is a separate binary that Terraform launches as a child process.

```
┌──────────────────┐         gRPC (Protocol Buffers)         ┌──────────────────┐
│  Terraform Core   │ ◄────────────────────────────────────► │  Provider Binary  │
│                    │    - GetProviderSchema                  │                    │
│  (plan, apply,     │    - ConfigureProvider                  │  (your code)       │
│   state mgmt)      │    - ReadResource / PlanResourceChange  │                    │
│                    │    - ApplyResourceChange                │                    │
│                    │    - ReadDataSource                     │                    │
│                    │    - CallFunction                       │                    │
└──────────────────┘                                          └──────────────────┘
```

### Plugin Framework vs SDKv2

| Aspect | Plugin Framework | SDKv2 (Legacy) |
|--------|-----------------|----------------|
| Status | **Recommended** for all new development | Maintenance mode — security fixes only |
| Go module | `github.com/hashicorp/terraform-plugin-framework` | `github.com/hashicorp/terraform-plugin-sdk/v2` |
| Schema model | Strongly typed with `schema.Attribute` | Map-based with `schema.Schema` |
| Plan customization | `planmodifier` package | `CustomizeDiff` |
| Validators | First-class `validator` package | `ValidateFunc` / `ValidateDiagFunc` |
| Functions | Supported (TF 1.8+) | Not supported |
| Diagnostics | Structured `diag.Diagnostics` | Structured `diag.Diagnostics` |

### Core Abstractions

- **Provider** — Configures shared clients (API keys, endpoints). One per provider binary.
- **Resource** — Manages a single infrastructure object lifecycle (CRUD + import).
- **Data Source** — Read-only lookup of existing infrastructure.
- **Function** (TF 1.8+) — Pure computation with no side effects, callable as `provider::name::func()`.

---

## Plugin Framework (Recommended for All New Development)

### Project Scaffolding

Start from the official scaffolding repository:

```bash
# Clone the scaffolding template
git clone https://github.com/hashicorp/terraform-provider-scaffolding-framework.git \
  terraform-provider-example
cd terraform-provider-example

# Rename the module
go mod edit -module github.com/yourorg/terraform-provider-example
grep -rl "hashicorp/terraform-provider-scaffolding-framework" . | \
  xargs sed -i '' 's|hashicorp/terraform-provider-scaffolding-framework|yourorg/terraform-provider-example|g'

go mod tidy
```

### Project Structure

```
terraform-provider-example/
├── main.go                          # Entry point — serves the provider
├── go.mod
├── internal/
│   └── provider/
│       ├── provider.go              # Provider definition + Configure()
│       ├── provider_test.go
│       ├── example_resource.go      # One file per resource
│       ├── example_resource_test.go
│       ├── example_data_source.go   # One file per data source
│       ├── example_data_source_test.go
│       ├── example_function.go      # One file per function
│       └── example_function_test.go
├── examples/                        # Example .tf files (used by tfplugindocs)
│   ├── provider/
│   ├── resources/
│   └── data-sources/
├── docs/                            # Generated by tfplugindocs
└── templates/                       # Custom doc templates (optional)
```

### Entry Point: main.go

```go
package main

import (
    "context"
    "flag"
    "log"

    "github.com/hashicorp/terraform-plugin-framework/providerserver"
    "github.com/yourorg/terraform-provider-example/internal/provider"
)

var version string = "dev"

func main() {
    var debug bool
    flag.BoolVar(&debug, "debug", false, "set to true to run the provider with support for debuggers like delve")
    flag.Parse()

    opts := providerserver.ServeOpts{
        Address: "registry.terraform.io/yourorg/example",
        Debug:   debug,
    }

    err := providerserver.Serve(context.Background(), provider.New(version), opts)
    if err != nil {
        log.Fatal(err.Error())
    }
}
```

### Provider Definition

The provider configures shared API clients and declares which resources, data sources, and functions it offers.

```go
package provider

import (
    "context"
    "os"

    "github.com/hashicorp/terraform-plugin-framework/datasource"
    "github.com/hashicorp/terraform-plugin-framework/function"
    "github.com/hashicorp/terraform-plugin-framework/provider"
    "github.com/hashicorp/terraform-plugin-framework/provider/schema"
    "github.com/hashicorp/terraform-plugin-framework/resource"
    "github.com/hashicorp/terraform-plugin-framework/types"
)

// Ensure interface compliance at compile time.
var _ provider.Provider = &ExampleProvider{}
var _ provider.ProviderWithFunctions = &ExampleProvider{}

type ExampleProvider struct {
    version string
}

type ExampleProviderModel struct {
    Endpoint types.String `tfsdk:"endpoint"`
    APIKey   types.String `tfsdk:"api_key"`
}

func New(version string) func() provider.Provider {
    return func() provider.Provider {
        return &ExampleProvider{version: version}
    }
}

func (p *ExampleProvider) Metadata(_ context.Context, _ provider.MetadataRequest, resp *provider.MetadataResponse) {
    resp.TypeName = "example"
    resp.Version = p.version
}

func (p *ExampleProvider) Schema(_ context.Context, _ provider.SchemaRequest, resp *provider.SchemaResponse) {
    resp.Schema = schema.Schema{
        Description: "Interact with the Example API.",
        Attributes: map[string]schema.Attribute{
            "endpoint": schema.StringAttribute{
                Description: "API endpoint URL. May also be set via EXAMPLE_ENDPOINT env var.",
                Optional:    true,
            },
            "api_key": schema.StringAttribute{
                Description: "API key for authentication. May also be set via EXAMPLE_API_KEY env var.",
                Optional:    true,
                Sensitive:   true,
            },
        },
    }
}

func (p *ExampleProvider) Configure(ctx context.Context, req provider.ConfigureRequest, resp *provider.ConfigureResponse) {
    var config ExampleProviderModel
    resp.Diagnostics.Append(req.Config.Get(ctx, &config)...)
    if resp.Diagnostics.HasError() {
        return
    }

    // Fall back to environment variables for unconfigured values.
    endpoint := os.Getenv("EXAMPLE_ENDPOINT")
    if !config.Endpoint.IsNull() {
        endpoint = config.Endpoint.ValueString()
    }
    if endpoint == "" {
        resp.Diagnostics.AddError(
            "Missing API Endpoint",
            "Set the endpoint in the provider block or via EXAMPLE_ENDPOINT.",
        )
        return
    }

    apiKey := os.Getenv("EXAMPLE_API_KEY")
    if !config.APIKey.IsNull() {
        apiKey = config.APIKey.ValueString()
    }
    if apiKey == "" {
        resp.Diagnostics.AddError(
            "Missing API Key",
            "Set api_key in the provider block or via EXAMPLE_API_KEY.",
        )
        return
    }

    // Create the API client and store it for resources/data sources.
    client := NewAPIClient(endpoint, apiKey)
    resp.DataSourceData = client
    resp.ResourceData = client
}

func (p *ExampleProvider) Resources(_ context.Context) []func() resource.Resource {
    return []func() resource.Resource{
        NewProjectResource,
    }
}

func (p *ExampleProvider) DataSources(_ context.Context) []func() datasource.DataSource {
    return []func() datasource.DataSource{
        NewProjectDataSource,
    }
}

func (p *ExampleProvider) Functions(_ context.Context) []func() function.Function {
    return []func() function.Function{
        NewSlugifyFunction,
    }
}
```

### Resource Lifecycle

Resources implement five methods: `Create`, `Read`, `Update`, `Delete`, and optionally `ImportState`. Each maps to a Terraform operation.

```
terraform plan    → Schema() + Read()
terraform apply   → Create() or Update() or Delete()
terraform import  → ImportState() + Read()
terraform destroy → Delete()
```

#### Resource Model and Schema

```go
package provider

import (
    "context"
    "fmt"

    "github.com/hashicorp/terraform-plugin-framework/path"
    "github.com/hashicorp/terraform-plugin-framework/resource"
    "github.com/hashicorp/terraform-plugin-framework/resource/schema"
    "github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier"
    "github.com/hashicorp/terraform-plugin-framework/resource/schema/stringplanmodifier"
    "github.com/hashicorp/terraform-plugin-framework/types"
    "github.com/hashicorp/terraform-plugin-log/tflog"
)

// Compile-time interface checks.
var _ resource.Resource = &ProjectResource{}
var _ resource.ResourceWithImportState = &ProjectResource{}

type ProjectResource struct {
    client *APIClient
}

type ProjectResourceModel struct {
    ID          types.String `tfsdk:"id"`
    Name        types.String `tfsdk:"name"`
    Description types.String `tfsdk:"description"`
    Status      types.String `tfsdk:"status"`
}

func NewProjectResource() resource.Resource {
    return &ProjectResource{}
}

func (r *ProjectResource) Metadata(_ context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
    resp.TypeName = req.ProviderTypeName + "_project"
}

func (r *ProjectResource) Schema(_ context.Context, _ resource.SchemaRequest, resp *resource.SchemaResponse) {
    resp.Schema = schema.Schema{
        Description: "Manages an Example project.",
        Attributes: map[string]schema.Attribute{
            "id": schema.StringAttribute{
                Description: "Project identifier. Set by the API on creation.",
                Computed:    true,
                PlanModifiers: []planmodifier.String{
                    stringplanmodifier.UseStateForUnknown(),
                },
            },
            "name": schema.StringAttribute{
                Description: "Human-readable project name.",
                Required:    true,
            },
            "description": schema.StringAttribute{
                Description: "Project description.",
                Optional:    true,
            },
            "status": schema.StringAttribute{
                Description: "Project status (active, archived). Set by the API.",
                Computed:    true,
            },
        },
    }
}

func (r *ProjectResource) Configure(_ context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
    if req.ProviderData == nil {
        return
    }
    client, ok := req.ProviderData.(*APIClient)
    if !ok {
        resp.Diagnostics.AddError(
            "Unexpected Resource Configure Type",
            fmt.Sprintf("Expected *APIClient, got: %T", req.ProviderData),
        )
        return
    }
    r.client = client
}
```

#### Create

```go
func (r *ProjectResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
    var plan ProjectResourceModel
    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
    if resp.Diagnostics.HasError() {
        return
    }

    tflog.Debug(ctx, "Creating project", map[string]interface{}{
        "name": plan.Name.ValueString(),
    })

    // Call the API.
    project, err := r.client.CreateProject(CreateProjectRequest{
        Name:        plan.Name.ValueString(),
        Description: plan.Description.ValueString(),
    })
    if err != nil {
        resp.Diagnostics.AddError(
            "Error Creating Project",
            "Could not create project: "+err.Error(),
        )
        return
    }

    // Map API response to Terraform state.
    plan.ID = types.StringValue(project.ID)
    plan.Status = types.StringValue(project.Status)

    resp.Diagnostics.Append(resp.State.Set(ctx, plan)...)
}
```

#### Read

```go
func (r *ProjectResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
    var state ProjectResourceModel
    resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
    if resp.Diagnostics.HasError() {
        return
    }

    project, err := r.client.GetProject(state.ID.ValueString())
    if err != nil {
        // If the resource no longer exists, remove it from state.
        resp.State.RemoveResource(ctx)
        return
    }

    // Update state with current API values.
    state.Name = types.StringValue(project.Name)
    state.Description = types.StringValue(project.Description)
    state.Status = types.StringValue(project.Status)

    resp.Diagnostics.Append(resp.State.Set(ctx, state)...)
}
```

#### Update

```go
func (r *ProjectResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
    var plan ProjectResourceModel
    resp.Diagnostics.Append(req.Plan.Get(ctx, &plan)...)
    if resp.Diagnostics.HasError() {
        return
    }

    var state ProjectResourceModel
    resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
    if resp.Diagnostics.HasError() {
        return
    }

    tflog.Debug(ctx, "Updating project", map[string]interface{}{
        "id": state.ID.ValueString(),
    })

    project, err := r.client.UpdateProject(state.ID.ValueString(), UpdateProjectRequest{
        Name:        plan.Name.ValueString(),
        Description: plan.Description.ValueString(),
    })
    if err != nil {
        resp.Diagnostics.AddError(
            "Error Updating Project",
            "Could not update project "+state.ID.ValueString()+": "+err.Error(),
        )
        return
    }

    // Preserve the ID from state; update everything else from the API.
    plan.ID = state.ID
    plan.Status = types.StringValue(project.Status)

    resp.Diagnostics.Append(resp.State.Set(ctx, plan)...)
}
```

#### Delete

```go
func (r *ProjectResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
    var state ProjectResourceModel
    resp.Diagnostics.Append(req.State.Get(ctx, &state)...)
    if resp.Diagnostics.HasError() {
        return
    }

    tflog.Debug(ctx, "Deleting project", map[string]interface{}{
        "id": state.ID.ValueString(),
    })

    err := r.client.DeleteProject(state.ID.ValueString())
    if err != nil {
        resp.Diagnostics.AddError(
            "Error Deleting Project",
            "Could not delete project "+state.ID.ValueString()+": "+err.Error(),
        )
        return
    }

    // State is automatically removed when Delete returns without error.
}
```

#### ImportState

```go
func (r *ProjectResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
    // The import ID is the project ID. Pass it through to the "id" attribute,
    // then Terraform calls Read() to populate the rest of the state.
    resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}
```

Usage:

```bash
terraform import example_project.myproject proj-abc123
```

### Data Sources: Read-Only Lookups

Data sources let users reference existing infrastructure without managing its lifecycle.

```go
package provider

import (
    "context"
    "fmt"

    "github.com/hashicorp/terraform-plugin-framework/datasource"
    "github.com/hashicorp/terraform-plugin-framework/datasource/schema"
    "github.com/hashicorp/terraform-plugin-framework/types"
)

var _ datasource.DataSource = &ProjectDataSource{}

type ProjectDataSource struct {
    client *APIClient
}

type ProjectDataSourceModel struct {
    ID          types.String `tfsdk:"id"`
    Name        types.String `tfsdk:"name"`
    Description types.String `tfsdk:"description"`
    Status      types.String `tfsdk:"status"`
}

func NewProjectDataSource() datasource.DataSource {
    return &ProjectDataSource{}
}

func (d *ProjectDataSource) Metadata(_ context.Context, req datasource.MetadataRequest, resp *datasource.MetadataResponse) {
    resp.TypeName = req.ProviderTypeName + "_project"
}

func (d *ProjectDataSource) Schema(_ context.Context, _ datasource.SchemaRequest, resp *datasource.SchemaResponse) {
    resp.Schema = schema.Schema{
        Description: "Look up an existing Example project by ID.",
        Attributes: map[string]schema.Attribute{
            "id": schema.StringAttribute{
                Description: "Project identifier.",
                Required:    true,
            },
            "name": schema.StringAttribute{
                Description: "Project name.",
                Computed:    true,
            },
            "description": schema.StringAttribute{
                Description: "Project description.",
                Computed:    true,
            },
            "status": schema.StringAttribute{
                Description: "Project status.",
                Computed:    true,
            },
        },
    }
}

func (d *ProjectDataSource) Configure(_ context.Context, req datasource.ConfigureRequest, resp *datasource.ConfigureResponse) {
    if req.ProviderData == nil {
        return
    }
    client, ok := req.ProviderData.(*APIClient)
    if !ok {
        resp.Diagnostics.AddError(
            "Unexpected Data Source Configure Type",
            fmt.Sprintf("Expected *APIClient, got: %T", req.ProviderData),
        )
        return
    }
    d.client = client
}

func (d *ProjectDataSource) Read(ctx context.Context, req datasource.ReadRequest, resp *datasource.ReadResponse) {
    var config ProjectDataSourceModel
    resp.Diagnostics.Append(req.Config.Get(ctx, &config)...)
    if resp.Diagnostics.HasError() {
        return
    }

    project, err := d.client.GetProject(config.ID.ValueString())
    if err != nil {
        resp.Diagnostics.AddError(
            "Error Reading Project",
            "Could not read project "+config.ID.ValueString()+": "+err.Error(),
        )
        return
    }

    config.Name = types.StringValue(project.Name)
    config.Description = types.StringValue(project.Description)
    config.Status = types.StringValue(project.Status)

    resp.Diagnostics.Append(resp.State.Set(ctx, config)...)
}
```

Usage in Terraform:

```hcl
data "example_project" "existing" {
  id = "proj-abc123"
}

output "project_name" {
  value = data.example_project.existing.name
}
```

### Provider-Defined Functions (Terraform 1.8+)

Functions are pure computations — no side effects, no API calls. They are called in HCL using `provider::name::func()` syntax.

```go
package provider

import (
    "context"
    "regexp"
    "strings"

    "github.com/hashicorp/terraform-plugin-framework/function"
)

var _ function.Function = &SlugifyFunction{}

type SlugifyFunction struct{}

func NewSlugifyFunction() function.Function {
    return &SlugifyFunction{}
}

func (f *SlugifyFunction) Metadata(_ context.Context, _ function.MetadataRequest, resp *function.MetadataResponse) {
    resp.Name = "slugify"
}

func (f *SlugifyFunction) Definition(_ context.Context, _ function.DefinitionRequest, resp *function.DefinitionResponse) {
    resp.Definition = function.Definition{
        Summary:     "Convert a string to a URL-safe slug.",
        Description: "Lowercases, replaces spaces and special characters with hyphens, removes consecutive hyphens.",
        Parameters: []function.Parameter{
            function.StringParameter{
                Name:        "input",
                Description: "The string to slugify.",
            },
        },
        Return: function.StringReturn{},
    }
}

func (f *SlugifyFunction) Run(ctx context.Context, req function.RunRequest, resp *function.RunResponse) {
    var input string
    resp.Error = function.ConcatFuncErrors(req.Arguments.Get(ctx, &input))
    if resp.Error != nil {
        return
    }

    slug := strings.ToLower(input)
    slug = regexp.MustCompile(`[^a-z0-9]+`).ReplaceAllString(slug, "-")
    slug = strings.Trim(slug, "-")

    resp.Error = function.ConcatFuncErrors(resp.Result.Set(ctx, slug))
}
```

Usage in Terraform:

```hcl
terraform {
  required_providers {
    example = {
      source = "yourorg/example"
    }
  }
}

locals {
  project_slug = provider::example::slugify("My Cool Project!")
  # Result: "my-cool-project"
}
```

---

## Legacy SDKv2 (Maintenance Mode)

### When You Will Encounter It

SDKv2 remains in production across hundreds of existing providers, including major ones (AWS, GCP, Azure). You will encounter it when:

- Contributing to existing providers that have not migrated
- Maintaining an internal provider originally written with SDKv2
- Reading provider source code or examples from before 2023

**Do not use SDKv2 for new providers.** HashiCorp announced maintenance mode in 2022 and recommends the Plugin Framework for all new development.

### Key Differences from Plugin Framework

| Aspect | SDKv2 | Plugin Framework |
|--------|-------|-----------------|
| Schema definition | `map[string]*schema.Schema` | `schema.Schema` with typed `Attribute` |
| CRUD methods | `CreateContext`, `ReadContext`, `UpdateContext`, `DeleteContext` | `Create`, `Read`, `Update`, `Delete` on a `Resource` interface |
| Data access | `d.Get("name")`, `d.Set("name", val)` | Strongly typed models with `tfsdk` struct tags |
| State ID | `d.SetId("")` to signal deletion | `resp.State.RemoveResource(ctx)` |
| Plan customization | `CustomizeDiff` function | `planmodifier` package with typed modifiers |
| Validators | `ValidateFunc` / `ValidateDiagFunc` | `validator` package with typed validators |
| Functions | Not supported | Supported via `function.Function` interface |

### SDKv2 Resource Example (for reference)

```go
func resourceProject() *schema.Resource {
    return &schema.Resource{
        CreateContext: resourceProjectCreate,
        ReadContext:   resourceProjectRead,
        UpdateContext: resourceProjectUpdate,
        DeleteContext: resourceProjectDelete,
        Importer: &schema.ResourceImporter{
            StateContext: schema.ImportStatePassthroughContext,
        },
        Schema: map[string]*schema.Schema{
            "name": {
                Type:        schema.TypeString,
                Required:    true,
                Description: "Project name.",
            },
            "description": {
                Type:        schema.TypeString,
                Optional:    true,
                Description: "Project description.",
            },
            "status": {
                Type:        schema.TypeString,
                Computed:    true,
                Description: "Project status.",
            },
        },
    }
}

func resourceProjectCreate(ctx context.Context, d *schema.ResourceData, meta interface{}) diag.Diagnostics {
    client := meta.(*APIClient)
    project, err := client.CreateProject(CreateProjectRequest{
        Name:        d.Get("name").(string),
        Description: d.Get("description").(string),
    })
    if err != nil {
        return diag.FromErr(err)
    }
    d.SetId(project.ID)
    return resourceProjectRead(ctx, d, meta)
}
```

### Migration Strategy: Mux Server

You do not need to migrate an entire provider at once. The **mux server** lets you run Plugin Framework and SDKv2 resources side by side in the same provider binary. Migrate resource by resource across multiple releases.

```go
package main

import (
    "context"
    "log"

    "github.com/hashicorp/terraform-plugin-framework/providerserver"
    "github.com/hashicorp/terraform-plugin-go/tfprotov6"
    "github.com/hashicorp/terraform-plugin-go/tfprotov6/tf6server"
    "github.com/hashicorp/terraform-plugin-mux/tf6muxserver"

    frameworkProvider "github.com/yourorg/terraform-provider-example/internal/provider"
    sdkv2Provider "github.com/yourorg/terraform-provider-example/internal/provider_sdkv2"
)

func main() {
    ctx := context.Background()

    // Wrap the SDKv2 provider to speak protocol v6.
    upgradedSdkProvider, err := tf6muxserver.NewMuxServer(
        ctx,
        // Plugin Framework provider (new resources go here).
        providerserver.NewProtocol6(frameworkProvider.New("dev")()),
        // SDKv2 provider (legacy resources, migrated one at a time).
        sdkv2Provider.New("dev")().GRPCProvider,
    )
    if err != nil {
        log.Fatal(err)
    }

    var serveOpts []tf6server.ServeOpt

    err = tf6server.Serve(
        "registry.terraform.io/yourorg/example",
        func() tfprotov6.ProviderServer { return upgradedSdkProvider },
        serveOpts...,
    )
    if err != nil {
        log.Fatal(err)
    }
}
```

**Migration workflow:**

1. Set up the mux server (one-time)
2. Pick a resource to migrate (start with the simplest)
3. Rewrite it using Plugin Framework interfaces
4. Move it from the SDKv2 provider factory to the Framework provider factory
5. Run existing acceptance tests — they should pass unchanged
6. Release, repeat for the next resource

---

## Testing Custom Providers

### Acceptance Tests

The `terraform-plugin-testing` package drives real Terraform operations against your provider. Tests create, read, update, and destroy real resources.

```go
package provider_test

import (
    "fmt"
    "testing"

    "github.com/hashicorp/terraform-plugin-testing/helper/resource"
    "github.com/hashicorp/terraform-plugin-testing/plancheck"
    "github.com/hashicorp/terraform-plugin-testing/statecheck"
    "github.com/hashicorp/terraform-plugin-testing/tfjsonpath"
)

func TestAccProjectResource_basic(t *testing.T) {
    resource.Test(t, resource.TestCase{
        ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
        Steps: []resource.TestStep{
            // Step 1: Create and verify.
            {
                Config: `
                    resource "example_project" "test" {
                        name        = "acceptance-test-project"
                        description = "Created by acceptance test"
                    }
                `,
                Check: resource.ComposeAggregateTestCheck(
                    resource.TestCheckResourceAttrSet("example_project.test", "id"),
                    resource.TestCheckResourceAttr("example_project.test", "name", "acceptance-test-project"),
                    resource.TestCheckResourceAttr("example_project.test", "status", "active"),
                ),
            },
            // Step 2: ImportState — verify import works.
            {
                ResourceName:            "example_project.test",
                ImportState:             true,
                ImportStateVerify:       true,
            },
            // Step 3: Update and verify.
            {
                Config: `
                    resource "example_project" "test" {
                        name        = "updated-project-name"
                        description = "Updated by acceptance test"
                    }
                `,
                Check: resource.ComposeAggregateTestCheck(
                    resource.TestCheckResourceAttr("example_project.test", "name", "updated-project-name"),
                ),
            },
        },
    })
}
```

### Plan Checks

Verify expected plan behavior (e.g., a change should trigger replacement, or a value should be known at plan time):

```go
{
    Config: `
        resource "example_project" "test" {
            name = "force-replace-project"
        }
    `,
    ConfigPlanChecks: resource.ConfigPlanChecks{
        PreApply: []plancheck.PlanCheck{
            plancheck.ExpectResourceAction("example_project.test", plancheck.ResourceActionReplace),
        },
    },
},
```

### State Checks

Verify state values after apply using the `statecheck` package:

```go
{
    Config: `
        resource "example_project" "test" {
            name = "state-check-project"
        }
    `,
    ConfigStateChecks: []statecheck.StateCheck{
        statecheck.ExpectKnownValue(
            "example_project.test",
            tfjsonpath.New("status"),
            knownvalue.StringExact("active"),
        ),
    },
},
```

### Sweepers for Leaked Resource Cleanup

When acceptance tests fail mid-run, resources may leak. Sweepers clean them up:

```go
func init() {
    resource.AddTestSweepers("example_project", &resource.Sweeper{
        Name: "example_project",
        F: func(region string) error {
            client := getTestClient()
            projects, err := client.ListProjects()
            if err != nil {
                return err
            }
            for _, p := range projects {
                if strings.HasPrefix(p.Name, "acceptance-test-") {
                    _ = client.DeleteProject(p.ID)
                }
            }
            return nil
        },
    })
}
```

Run sweepers:

```bash
go test ./internal/provider/ -v -sweep=us-east-1 -timeout 10m
```

### Running Acceptance Tests

Acceptance tests are gated behind the `TF_ACC` environment variable to prevent accidental runs:

```bash
# Run all acceptance tests
TF_ACC=1 go test ./internal/provider/ -v -timeout 120m

# Run a specific test
TF_ACC=1 go test ./internal/provider/ -v -run TestAccProjectResource_basic -timeout 120m

# With parallelism control
TF_ACC=1 go test ./internal/provider/ -v -parallel 4 -timeout 120m
```

---

## Debugging Providers

### Log-Based Debugging

Set environment variables to control log output:

```bash
# Provider-specific logs (most useful — isolates from Terraform core noise)
TF_LOG_PROVIDER=TRACE terraform apply

# All logs (very verbose)
TF_LOG=TRACE terraform apply

# Write logs to a file
TF_LOG_PROVIDER=TRACE TF_LOG_PATH=provider.log terraform apply
```

Use `tflog` in your provider code for structured logging:

```go
import "github.com/hashicorp/terraform-plugin-log/tflog"

tflog.Debug(ctx, "Creating project", map[string]interface{}{
    "name":    plan.Name.ValueString(),
    "api_url": r.client.Endpoint,
})
```

### Delve Debugger

For interactive debugging with breakpoints:

```bash
# Build the provider with debug support
go build -gcflags="all=-N -l" -o terraform-provider-example

# Start with the -debug flag — it prints a TF_REATTACH_PROVIDERS value
./terraform-provider-example -debug
# Output: TF_REATTACH_PROVIDERS='{"registry.terraform.io/yourorg/example":{...}}'
```

In another terminal:

```bash
# Paste the TF_REATTACH_PROVIDERS value, then run Terraform normally
export TF_REATTACH_PROVIDERS='{"registry.terraform.io/yourorg/example":{...}}'
terraform apply
```

Terraform will connect to your already-running provider binary instead of launching a new one, so your debugger breakpoints will be hit.

### Dev Overrides for Local Testing

Skip the registry entirely during development by adding dev overrides to `~/.terraformrc`:

```hcl
provider_installation {
  dev_overrides {
    "yourorg/example" = "/home/you/go/bin"
  }

  # Fall back to the registry for everything else.
  direct {}
}
```

With dev overrides active:
- `terraform init` is not required (and will warn that overrides are active)
- Terraform uses the binary at the specified path directly
- You rebuild with `go install` and re-run `terraform plan/apply`

**Remove dev overrides before committing or running CI** — they bypass version constraints and checksums.

---

## Documentation Generation

The `tfplugindocs` tool generates provider documentation from your code's schema descriptions.

### Setup and Usage

```bash
# Install
go install github.com/hashicorp/terraform-plugin-docs/cmd/tfplugindocs@latest

# Generate docs (run from provider root)
tfplugindocs generate

# Validate generated docs
tfplugindocs validate
```

### How It Works

1. Reads `Schema()` from your provider, resources, and data sources
2. Extracts `Description` fields from every attribute
3. Looks for example `.tf` files in `examples/`
4. Generates Markdown files in `docs/`

**Generated structure:**

```
docs/
├── index.md                          # Provider configuration
├── resources/
│   └── project.md                    # example_project resource
├── data-sources/
│   └── project.md                    # example_project data source
└── functions/
    └── slugify.md                    # slugify function
```

### Example Files

Place example Terraform configurations in `examples/` for inclusion in docs:

```
examples/
├── provider/
│   └── provider.tf                   # Provider configuration example
├── resources/
│   └── example_project/
│       ├── resource.tf               # Basic usage
│       └── import.sh                 # Import command example
├── data-sources/
│   └── example_project/
│       └── data-source.tf
└── functions/
    └── slugify/
        └── function.tf
```

### Custom Templates

Override generated output with Go templates in `templates/`:

```
templates/
├── index.md.tmpl                     # Custom provider page
└── resources/
    └── project.md.tmpl               # Custom resource page
```

The Terraform Registry renders `docs/` automatically on each release — no manual upload needed.

---

## Publishing to the Registry

### Prerequisites

1. **Repository naming**: Must be `terraform-provider-<NAME>` (e.g., `terraform-provider-example`)
2. **GPG signing key**: RSA or DSA key. The public key is uploaded to the Registry.
3. **GoReleaser**: Builds cross-platform binaries and creates GitHub Releases
4. **GitHub Actions**: Automates the release pipeline

### GoReleaser Configuration

Create `.goreleaser.yml` in the provider root:

```yaml
# .goreleaser.yml
version: 2

builds:
  - env:
      - CGO_ENABLED=0
    mod_timestamp: "{{ .CommitTimestamp }}"
    flags:
      - -trimpath
    ldflags:
      - "-s -w -X main.version={{ .Version }}"
    goos:
      - linux
      - darwin
      - windows
    goarch:
      - amd64
      - arm64
    binary: "{{ .ProjectName }}_v{{ .Version }}"

archives:
  - format: zip
    name_template: "{{ .ProjectName }}_{{ .Version }}_{{ .Os }}_{{ .Arch }}"

checksum:
  name_template: "{{ .ProjectName }}_{{ .Version }}_SHA256SUMS"
  algorithm: sha256

signs:
  - artifacts: checksum
    args:
      - "--batch"
      - "--local-user"
      - "{{ .Env.GPG_FINGERPRINT }}"
      - "--output"
      - "${signature}"
      - "--detach-sign"
      - "${artifact}"

release:
  draft: false

changelog:
  sort: asc
  filters:
    exclude:
      - "^docs:"
      - "^test:"
      - "^chore:"
```

### GitHub Actions Workflow

Create `.github/workflows/release.yml`:

```yaml
name: Release

on:
  push:
    tags:
      - "v*"

permissions:
  contents: write

jobs:
  goreleaser:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: actions/setup-go@v5
        with:
          go-version-file: "go.mod"

      - name: Import GPG key
        uses: crazy-max/ghaction-import-gpg@v6
        id: import_gpg
        with:
          gpg_private_key: ${{ secrets.GPG_PRIVATE_KEY }}
          passphrase: ${{ secrets.GPG_PASSPHRASE }}

      - name: Run GoReleaser
        uses: goreleaser/goreleaser-action@v6
        with:
          args: release --clean
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GPG_FINGERPRINT: ${{ steps.import_gpg.outputs.fingerprint }}
```

### Release Process

```bash
# Ensure docs are current
tfplugindocs generate
git add docs/
git commit -m "docs: regenerate provider documentation"

# Tag with semver
git tag v1.0.0
git push origin v1.0.0
# GitHub Actions builds, signs, and publishes the release
```

### Registry Publishing

1. Sign in to [registry.terraform.io](https://registry.terraform.io/) with your GitHub account
2. Click **Publish** > **Provider**
3. Select the `terraform-provider-<NAME>` repository
4. Upload your GPG public key
5. The Registry indexes each GitHub Release automatically

---

## Alternative Approaches

### CDKTF (Cloud Development Kit for Terraform)

**DEPRECATED.** HashiCorp announced the deprecation of CDKTF in December 2025, and the repository was archived shortly after. Existing CDKTF projects should migrate to either native HCL or Pulumi.

- CDKTF allowed writing Terraform configurations in TypeScript, Python, Java, C#, and Go
- It synthesized HCL JSON under the hood — the actual provider and state machinery was still Terraform
- If you have existing CDKTF code, it can be converted to HCL using `cdktf synth` to produce the JSON, then `terraform show` on the resulting plan

### Pulumi

Pulumi uses real programming languages (TypeScript, Python, Go, C#, Java, YAML) with actual control flow, loops, and conditionals — not a DSL that compiles to JSON.

**Key differences from Terraform:**

| Aspect | Terraform | Pulumi |
|--------|-----------|--------|
| Language | HCL (DSL) | TypeScript, Python, Go, C#, Java, YAML |
| State | Local file, S3, Terraform Cloud, etc. | Pulumi Cloud (free tier), S3, local |
| Provider count | ~4,800+ | ~150+ native, plus Terraform bridge |
| Plan equivalent | `terraform plan` | `pulumi preview` |
| Ecosystem maturity | Dominant, massive community | Growing, strong in TypeScript/Python |
| Custom providers | Go only | Any supported language |

**When Pulumi makes sense:** Teams that strongly prefer TypeScript/Python, need complex logic in infrastructure code, or want a unified language across application and infrastructure.

**When Terraform still wins:** Larger ecosystem, more providers, more hiring pool, more community modules.

### OpenTofu

OpenTofu is an MPL 2.0-licensed fork of Terraform, created in response to HashiCorp's BSL license change in August 2023.

- **Compatible with Terraform 1.5.x features** — drop-in replacement for configurations at that level
- **Adds state encryption** — client-side encryption of state files, not available in Terraform
- **Registry**: Uses its own registry at [registry.opentofu.org](https://registry.opentofu.org/), but can consume existing Terraform providers
- **Divergence**: Feature development has diverged — some Terraform 1.6+ features (import blocks, `removed` blocks) were independently implemented with slightly different semantics
- **Providers**: Existing Terraform providers work with OpenTofu without modification

**Migration**: Replace `terraform` binary with `tofu`. For most configurations, no code changes are needed.

### Terragrunt 1.0

Terragrunt 1.0, released March 2026 by Gruntwork, is a DRY wrapper around Terraform/OpenTofu that eliminates configuration duplication across environments.

**Key features:**

- **DRY configurations**: Define a module once, parameterize per environment via `terragrunt.hcl` includes
- **Dependency orchestration**: `dependency` blocks handle cross-module outputs and apply ordering
- **Stacks**: New in 1.0 — define a group of Terragrunt units as a deployable stack with `terragrunt stack plan/apply`
- **Remote state management**: Auto-configures S3/GCS/Azure backends with locking
- **Before/after hooks**: Run scripts or commands around plan/apply lifecycle events
- **`run`**: New in 1.0 — execute arbitrary commands (`run { command = "kubectl" ... }`) within the Terragrunt workflow

**Terragrunt does NOT replace providers.** It wraps Terraform/OpenTofu and adds orchestration. You still write HCL modules, you still use providers — Terragrunt removes the boilerplate of calling those modules across environments.

---

## Further Reading

- [Plugin Framework documentation](https://developer.hashicorp.com/terraform/plugin/framework) — Official guide, the primary reference
- [terraform-plugin-framework repository](https://github.com/hashicorp/terraform-plugin-framework) — Source code and examples
- [terraform-plugin-testing](https://github.com/hashicorp/terraform-plugin-testing) — Test framework documentation
- [terraform-plugin-docs](https://github.com/hashicorp/terraform-plugin-docs) — Documentation generator
- [Terraform Registry publishing guide](https://developer.hashicorp.com/terraform/registry/providers/publishing)
- [Call a Provider-Defined Function tutorial](https://developer.hashicorp.com/terraform/plugin/framework/functions)
- [Mux server migration guide](https://developer.hashicorp.com/terraform/plugin/mux)
