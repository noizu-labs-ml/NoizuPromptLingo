# smart_token (0.1.2)

Stateful token generation and validation with time/use/IP constraints and access audit trail.

## Installation
```elixir
{:smart_token, "~> 0.1.2"}
```

## Setup
```elixir
# config.exs
config :smart_token, repo: MyApp.Repo

# Migration
defmodule MyApp.Repo.Migrations.SetupSmartTokens do
  use Ecto.Migration
  def up(), do: SmartToken.Migration.up(1)
  def down(), do: SmartToken.Migration.down(1)
end
```

## Creating Tokens

```elixir
token = SmartToken.new(%{
  active: true,
  type: :account_verification,
  resource: {:bind, :recipient},
  context: {:bind, :recipient},
  scope: {:account_info, :verification},
  validity_period: {:unbound, {:relative, [{:day, 3}]}},
  extended_info: %{single_use: true}
})

# Bind dynamic values
bindings = %{recipient: %User{id: 42}}
{:ok, saved} = SmartToken.bind!(token, bindings, Noizu.Context.admin())

# Get shareable key
token_key = SmartToken.encoded_key(saved)
```

### Chainable Constraints
```elixir
token
|> SmartToken.single_use()
|> SmartToken.multi_use(5)
|> SmartToken.unlimited_use()
|> SmartToken.validity_period({:unbound, {:relative, [{:day, 3}]}})
|> SmartToken.ip_whitelist("192.168.1.0/24")
|> SmartToken.session_value("browser_id", "abc123")
```

### Preset Tokens
```elixir
SmartToken.account_verification_token(options)
```

## Validating Tokens

```elixir
# Full validation + access recording
{:ok, token} = SmartToken.authorize!(token_key, conn, context, options)

# Validation only (no recording)
{:ok, token} = SmartToken.validate(token, conn, context, options)
```

### Individual Validators
```elixir
SmartToken.validate_period(token, options)
SmartToken.validate_access_count(token)
SmartToken.validate_remote_ip(token, conn)
SmartToken.validate_session_values(token, conn)
```

## Access Audit
```elixir
SmartToken.record_valid_access!(token, conn, options)
SmartToken.record_invalid_access!(token, error, conn, options)
SmartToken.access_count(token)
# access_history: %{count: int, history: [{time, ip, type}, ...]}
```

## Key Concepts
1. **Dual-token design** — token_a + token_b combined via ShortUUID (prevents partial leakage)
2. **Bind pattern** — `{:bind, :key}` in token def, resolved at `bind!/3` time
3. **Relative time windows** — `{:relative, [{:day, 3}]}` = 3 days from bind time
4. **Constraint stacking** — Multiple constraints checked in single `authorize!` call
