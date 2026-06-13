# Kubernetes platform — Terragrunt orchestration

Terragrunt drives the Terraform stacks in this repo from this directory. Each
stack (`init`, and later `infra`, `infra-services`, …) is a Terragrunt **unit**
(a directory with a `terragrunt.hcl`). Shared settings live in `root.hcl`, which
every unit includes.

## Run everything from here

```bash
# from this directory (terraform/kubernetes)
# NOTE: `run --all` forwards OpenTofu/Terraform flags only after a `--` separator.
terragrunt run --all plan       # preview the whole stack, in dependency order
terragrunt run --all apply      # apply the whole stack, in dependency order
terragrunt run --all destroy    # tear down, in reverse dependency order

# Forward tofu flags (e.g. -input=false, -lock=false) AFTER `--`:
terragrunt run --all plan -- -input=false -lock=false
```

Terragrunt discovers units automatically. Today only `init` exists, so
`run --all apply` applies just `init`. As you add `infra/terragrunt.hcl`,
`infra-services/terragrunt.hcl`, etc. they join the run automatically — ordered
by their `dependencies` blocks (see below).

Run a single unit directly when you need to:

```bash
cd init && terragrunt apply
```

## Dependency ordering

`init` keeps **local** state and is the bootstrap (it deploys MinIO and creates
the `tfstate` bucket every other stack uses as its S3 backend). The downstream
stacks read init's outputs through a Terraform `terraform_remote_state` data
source pointed at `../init/terraform.tfstate` — that is *runtime wiring*, and
Terragrunt's DAG does **not** infer ordering from it.

So each downstream unit must declare the ordering explicitly with a
`dependencies` block. When you add `infra`, create `infra/terragrunt.hcl`:

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Run init before infra. (Data still flows via the terraform_remote_state data
# source in infra/remote-state.tf; this block only controls run --all ordering.)
dependencies {
  paths = ["../init"]
}
```

`infra-services` depends on `init` (and on `infra` once that's wired):

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../init", "../infra"]
}
```

Unlike `init`, the downstream units already declare their own `backend "s3"`
(MinIO) block in `provider.tf`, so `root.hcl` stays backend-agnostic and does not
generate one. Supply backend credentials at apply time:

```bash
export AWS_ACCESS_KEY_ID=<minio_root_user>
export AWS_SECRET_ACCESS_KEY=<minio_root_password>
terragrunt run --all apply
```

## Cluster target

`root.hcl` passes the kubeconfig to every unit. Override without editing files:

```bash
export KUBE_CONFIG_PATH=~/.kube/noizu/config
export KUBE_CONFIG_CONTEXT=noizu
```
