# TODO: Replace with actual resources
#
# Guidelines:
# - Use for_each for collections (not count)
# - Use locals for computed values
# - Reference variables via var.* prefix
# - Name single-instance resources "this"
# - Don't repeat resource type in resource name

resource "example_resource" "this" {
  name = var.name

  tags = var.tags
}
