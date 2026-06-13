dir = Path.dirname(__ENV__.file)
Code.eval_file("#{dir}/auth_providers/001-providers.exs")
Code.eval_file("#{dir}/auth_providers/002-sso-providers.exs")
