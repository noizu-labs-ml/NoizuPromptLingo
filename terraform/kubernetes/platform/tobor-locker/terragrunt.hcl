include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../../init", "../../infra", "../../infra-services", "../init"]
}

inputs = {
  init_state_path = "${get_terragrunt_dir()}/../../init/terraform.tfstate"
}
