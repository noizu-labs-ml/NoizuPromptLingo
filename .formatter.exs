# Used by "mix format"
locals_without_parens = [
  tool: 1,
  tool: 2,
  resource: 1,
  resource: 2,
  resource_template: 1,
  resource_template: 2,
  prompt: 1,
  prompt: 2,
  field: 2,
  field: 3,
  field: 4,
  arg: 1,
  arg: 2,
  input_schema: 1,
  output_schema: 1
]

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens]
]
