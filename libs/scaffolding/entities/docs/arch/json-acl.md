# JSON Serialization & ACL

## JSON Encoding

Entities opt into JSON encoding with `jason_encoder()` inside `def_entity`. This generates a `Jason.Encoder` implementation that:

1. Selects a named JSON format template (`:default` or custom) from `__noizu_meta__().json`
2. Calls `Noizu.Entity.Json.Protocol.prep/4` to build the output map
3. Passes the result to `Jason.Encode.map/2`

### Format Templates

JSON format templates are declared via `@json` attributes and expanded at compile time into maps of `{field_name => json_settings}`. Each format controls which fields appear in the output and how they're named.

### Custom Encoder Context

The Jason encoder supports a three-element tuple options format `{encoder, opts, user_settings}` where `user_settings` can specify:
- `json_format` — selects which format template to use
- `context` — the request context for ACL checks
- `settings` — additional options

## ACL Protocol

`Noizu.Entity.ACL.Protocol.restrict/5` is called during JSON prep to filter entity fields based on the caller's context. The default `Any` implementation passes all fields through (`:read` always returns `{:ok, entity}`).

### ACL Rules

ACL settings are derived at compile time from field attributes:
- `transient` fields → restricted to `[:admin, :system]` roles
- `pii :sensitive` or `pii :private` fields → restricted to `[:user, :admin, :system]`
- All other fields → `:unrestricted`

Custom ACL rules can be set via `@acl` attributes per field.

### Restricted Fields

During JSON prep, restricted fields are represented as `:"*restricted*"` atoms. The `embed_field/6` callback omits `nil`, `:"*restricted*"`, and `{:"*restricted*", _}` values from the output map.

## Processing Flow

```
Jason.Encoder.encode/2
  → select json_format template
  → Json.Protocol.prep/4
    → ACL.Protocol.restrict(:read, entity, acl_config, context, options)
    → for each {field, settings} in template:
      → embed_field (skip nil/restricted)
      → Json.Protocol.prep (recursive for nested entities)
    → build output map
```
