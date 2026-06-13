# ---------------------------------------------------------------------------
# Terragrunt wrapper for the `apps/init` stack.
# ---------------------------------------------------------------------------
# Publishes apps-tier shared services and app releases into the `apps`
# namespace. The module declares its own `backend "s3"` (MinIO) block in
# provider.tf (key apps/init/terraform.tfstate), so root.hcl stays
# backend-agnostic. Supply MinIO credentials as AWS_* env vars at apply time:
#
#   export AWS_ACCESS_KEY_ID=$(terraform -chdir=../../init output -raw minio_root_user)
#   export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=../../init output -raw minio_root_password)
#   terragrunt apply
#
# Run ordering: after init has bootstrapped MinIO/state and after
# infra-services has installed the Infisical operator + universal auth secret.

include "root" {
  path = find_in_parent_folders("root.hcl")
}

# This unit references ../../modules, which live outside the unit directory.
# Terragrunt copies only the source root into .terragrunt-cache, so point the
# copy root at terraform/kubernetes and run in apps/init via the // subdir.
terraform {
  source = "${get_terragrunt_dir()}/../..//apps/init"

  exclude_from_copy = [
    "cluster-backup-noizu-*",
    "infra",
    "infra-services",
    "init",
    "platform",
    "docs",
  ]
}

dependencies {
  paths = ["../../init", "../../infra-services"]
}

# Terraform runs from a .terragrunt-cache copy, so hand it absolute paths for
# the local init state and for the Helm chart that lives outside terraform/.
inputs = {
  init_state_path           = "${get_terragrunt_dir()}/../../init/terraform.tfstate"
  noizu_site_chart_path     = "${get_terragrunt_dir()}/../../../../projects/noizu.com/helm/noizu-site"
  aifighter_site_chart_path = "${get_terragrunt_dir()}/../../../../projects/aifighter.com/helm/aifighter"
  codefresh_chart_path      = "${get_terragrunt_dir()}/../../../../projects/codefre.sh/helm/codefresh"
  gottacc_site_chart_path   = "${get_terragrunt_dir()}/../../../../projects/gotta.cc/helm/gotta-cc"
  iotgo_site_chart_path     = "${get_terragrunt_dir()}/../../../../projects/iotgo.io/helm/iotgo"
  jailbreakingsite_chart_path = "${get_terragrunt_dir()}/../../../../projects/jailbreakingsite.com/helm/jailbreakingsite"
  noizurpg_chart_path         = "${get_terragrunt_dir()}/../../../../projects/noizurpg.com/helm/noizurpg"
  robotsunite_chart_path      = "${get_terragrunt_dir()}/../../../../projects/robots-unite.com/helm/robots-unite"
  therobotlives_chart_path    = "${get_terragrunt_dir()}/../../../../projects/therobotlives.com/helm/therobotlives"
  bladeofeternity_chart_path  = "${get_terragrunt_dir()}/../../../../projects/bladeofeternity.com/helm/bladeofeternity"
  therobotknows_chart_path    = "${get_terragrunt_dir()}/../../../../projects/therobotknows.com/helm/therobotknows"
  derobotis_chart_path        = "${get_terragrunt_dir()}/../../../../projects/derobot.is/helm/derobotis"
  therobotmakes_chart_path    = "${get_terragrunt_dir()}/../../../../projects/therobotmakes.com/helm/therobotmakes"
  tobornalp_chart_path        = "${get_terragrunt_dir()}/../../../../projects/tobornalp.com/app/helm/start-app"
  infra_portal_chart_path     = "${get_terragrunt_dir()}/../../../../projects/infra.noizu.com/helm/infra-portal"
}
