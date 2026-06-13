defmodule Noizu.MCP.Server.Tool.Fields do
  @moduledoc false
  # Compile-time machinery for tool schemas. Two front ends produce the same
  # `[%Field{}]` representation:
  #
  #   * `extract/2` — the `input do ... field ... end` macro DSL (AST)
  #   * `from_spec/1` — a plain data literal (keyword list), used by
  #     `@mcp input:`/`output:` toolkit annotations
  #
  # Fields compile to a JSON Schema map (string keys, wire-ready) via
  # `to_json_schema/1` and to a cast plan (`to_cast_plan/1`) used at runtime to
  # atomize keys, apply defaults, and cast enum values.

  @scalar_types [:string, :integer, :number, :boolean]

  defmodule Field do
    @moduledoc false
    defstruct [:name, :type, :opts, children: nil]
  end

  @doc "Extract `[%Field{}]` from the AST of an `input`/`output` block."
  def extract(block, caller) do
    block
    |> statements()
    |> Enum.map(&extract_field(&1, caller))
  end

  defp statements({:__block__, _, statements}), do: statements
  defp statements(nil), do: []
  defp statements(single), do: [single]

  defp extract_field({:field, _, args}, caller), do: extract_args(args, caller)

  defp extract_field(other, caller) do
    raise CompileError,
      file: caller.file,
      line: line_of(other, caller),
      description:
        "only `field name, type, opts` declarations are allowed inside input/output blocks, " <>
          "got: #{Macro.to_string(other)}"
  end

  defp extract_args([name, type], caller), do: build(name, type, [], nil, caller)

  defp extract_args([name, type, [do: block]], caller),
    do: build(name, type, [], block, caller)

  defp extract_args([name, type, opts], caller) do
    {block, opts} = Keyword.pop(opts_list(opts, caller), :do)
    build(name, type, opts, block, caller)
  end

  defp extract_args([name, type, opts, [do: block]], caller) do
    build(name, type, opts_list(opts, caller), block, caller)
  end

  defp extract_args(args, caller) do
    raise CompileError,
      file: caller.file,
      description: "invalid field declaration: field #{Macro.to_string(args)}"
  end

  defp opts_list(opts, caller) do
    {evaluated, _} = Code.eval_quoted(opts, [], caller)

    unless Keyword.keyword?(evaluated) do
      raise CompileError,
        file: caller.file,
        description: "field options must be a keyword list, got: #{inspect(evaluated)}"
    end

    evaluated
  end

  defp build(name, type_ast, opts, block, caller) do
    unless is_atom(name) do
      raise CompileError,
        file: caller.file,
        description: "field name must be an atom, got: #{Macro.to_string(name)}"
    end

    type = normalize_type(type_ast, caller)
    children = block && extract(block, caller)

    validate_type!(name, type, opts, children, caller)

    %Field{name: name, type: type, opts: opts, children: children}
  end

  defp normalize_type(type, _caller) when is_atom(type), do: type

  defp normalize_type({:{}, _, [marker, inner]}, caller),
    do: normalize_type({marker, inner}, caller)

  defp normalize_type({:array, inner}, caller), do: {:array, normalize_type(inner, caller)}

  defp normalize_type(other, caller) do
    raise CompileError,
      file: caller.file,
      description: "unknown field type: #{Macro.to_string(other)}"
  end

  defp validate_type!(name, type, opts, children, caller) do
    case check_type(name, type, opts, children) do
      :ok -> :ok
      {:error, message} -> compile_error!(caller, message)
    end
  end

  defp check_type(name, type, opts, children) do
    valid_scalar = type in @scalar_types
    valid_enum = type == :enum and is_list(opts[:values]) and opts[:values] != []
    valid_object = type == :object
    valid_array = match?({:array, _}, type)

    cond do
      type == :enum and not valid_enum ->
        {:error, "field #{name}: :enum requires values: [...]"}

      valid_object and (children == nil or children == []) ->
        {:error, "field #{name}: :object requires nested fields (a do-block or fields: [...])"}

      valid_array and elem(type, 1) == :object and children in [nil, []] ->
        {:error,
         "field #{name}: {:array, :object} requires nested fields (a do-block or fields: [...])"}

      valid_scalar or valid_enum or valid_object or valid_array ->
        :ok

      true ->
        {:error, "field #{name}: unknown type #{inspect(type)}"}
    end
  end

  @spec compile_error!(Macro.Env.t(), String.t()) :: no_return()
  defp compile_error!(caller, description) do
    raise CompileError, file: caller.file, description: description
  end

  defp line_of({_, meta, _}, caller), do: Keyword.get(meta, :line, caller.line)
  defp line_of(_, caller), do: caller.line

  # ── Data-form specs ───────────────────────────────────────────────────────

  @doc """
  Build `[%Field{}]` from a plain data spec (no AST) — the data equivalent of
  the `input do ... end` field DSL, used by `@mcp input:`/`output:` toolkit
  annotations:

      [
        message: [type: :string, required: true, description: "..."],
        repeat:  [type: :integer, min: 1, max: 10, default: 1],
        mode:    [type: :enum, values: [:plain, :loud], default: :plain],
        address: [type: :object, required: true, fields: [street: [type: :string]]],
        tags:    [type: {:array, :string}],
        rows:    [type: {:array, :object}, fields: [id: [type: :integer]]],
        note:    :string                       # shorthand: bare type
      ]

  `:type` is required (or use the bare-type shorthand); `:fields` carries
  children for `:object` / `{:array, :object}` entries; all other options pass
  through as field options. Raises `ArgumentError` on invalid specs (callers
  invoke this at compile time, so errors still surface during compilation).
  """
  def from_spec(spec) do
    unless Keyword.keyword?(spec) do
      raise ArgumentError,
            "field spec must be a keyword list of `name: type` or " <>
              "`name: [type: ..., ...]` entries, got: #{inspect(spec)}"
    end

    Enum.map(spec, &spec_field/1)
  end

  defp spec_field({name, type}) when is_atom(type),
    do: build_spec_field(name, type, [], nil)

  defp spec_field({name, {:array, inner}}) when is_atom(inner),
    do: build_spec_field(name, {:array, inner}, [], nil)

  defp spec_field({name, opts}) when is_list(opts) do
    unless Keyword.keyword?(opts) do
      raise ArgumentError, "field #{name}: options must be a keyword list, got: #{inspect(opts)}"
    end

    {type, opts} = Keyword.pop(opts, :type)
    {fields, opts} = Keyword.pop(opts, :fields)

    unless type do
      raise ArgumentError,
            "field #{name}: spec requires a :type (or use the `#{name}: :type` shorthand)"
    end

    children = fields && from_spec(fields)
    build_spec_field(name, type, opts, children)
  end

  defp spec_field({name, other}) do
    raise ArgumentError,
          "field #{name}: expected a type or an options keyword list, got: #{inspect(other)}"
  end

  defp build_spec_field(name, type, opts, children) do
    unless is_atom(name) do
      raise ArgumentError, "field name must be an atom, got: #{inspect(name)}"
    end

    type = spec_type(name, type)

    case check_type(name, type, opts, children) do
      :ok -> %Field{name: name, type: type, opts: opts, children: children}
      {:error, message} -> raise ArgumentError, message
    end
  end

  defp spec_type(_name, type) when is_atom(type), do: type
  defp spec_type(_name, {:array, inner}) when is_atom(inner), do: {:array, inner}

  defp spec_type(name, other),
    do: raise(ArgumentError, "field #{name}: unknown type #{inspect(other)}")

  # ── Raw schemas ───────────────────────────────────────────────────────────

  @doc """
  Normalize a raw schema given as a map or as JSON text. Binary input is
  decoded at the call site's compile time; the result must be a JSON object.
  `context` names the owning tool/module for error messages.
  """
  def decode_schema!(%{} = schema, _context), do: schema

  def decode_schema!(schema, context) when is_binary(schema) do
    case Jason.decode(schema) do
      {:ok, %{} = map} ->
        map

      {:ok, other} ->
        raise ArgumentError,
              "#{context}: JSON schema text must decode to an object, got: #{inspect(other)}"

      {:error, error} ->
        raise ArgumentError,
              "#{context}: invalid JSON schema text — #{Exception.message(error)}"
    end
  end

  def decode_schema!(other, context) do
    raise ArgumentError,
          "#{context}: expected a schema map or JSON text, got: #{inspect(other)}"
  end

  # ── JSON Schema compilation ───────────────────────────────────────────────

  @doc "Compile `[%Field{}]` to a JSON Schema object map (string keys)."
  def to_json_schema(fields) do
    properties = Map.new(fields, fn field -> {to_string(field.name), field_schema(field)} end)
    required = for field <- fields, field.opts[:required], do: to_string(field.name)

    %{"type" => "object", "properties" => properties}
    |> then(&if required == [], do: &1, else: Map.put(&1, "required", required))
  end

  defp field_schema(%Field{type: :object, children: children, opts: opts}) do
    children
    |> to_json_schema()
    |> apply_common_opts(opts)
  end

  defp field_schema(%Field{type: {:array, :object}, children: children, opts: opts}) do
    %{"type" => "array", "items" => to_json_schema(children)}
    |> apply_array_opts(opts)
  end

  defp field_schema(%Field{type: {:array, inner}, opts: opts}) do
    %{"type" => "array", "items" => scalar_schema(inner, [])}
    |> apply_array_opts(opts)
  end

  defp field_schema(%Field{type: type, opts: opts}), do: scalar_schema(type, opts)

  defp scalar_schema(:enum, opts) do
    %{"type" => "string", "enum" => Enum.map(opts[:values], &to_string/1)}
    |> apply_common_opts(opts)
  end

  defp scalar_schema(:string, opts) do
    %{"type" => "string"}
    |> put_opt(opts, :min_length, "minLength")
    |> put_opt(opts, :max_length, "maxLength")
    |> put_opt(opts, :pattern, "pattern")
    |> put_opt(opts, :format, "format")
    |> apply_common_opts(opts)
  end

  defp scalar_schema(type, opts) when type in [:integer, :number] do
    %{"type" => to_string(type)}
    |> put_opt(opts, :min, "minimum")
    |> put_opt(opts, :max, "maximum")
    |> apply_common_opts(opts)
  end

  defp scalar_schema(:boolean, opts) do
    apply_common_opts(%{"type" => "boolean"}, opts)
  end

  defp apply_array_opts(schema, opts) do
    schema
    |> put_opt(opts, :min, "minItems")
    |> put_opt(opts, :max, "maxItems")
    |> apply_common_opts(opts)
  end

  defp apply_common_opts(schema, opts) do
    schema
    |> put_opt(opts, :description, "description")
    |> then(fn s ->
      case Keyword.fetch(opts, :default) do
        {:ok, default} -> Map.put(s, "default", encode_default(default))
        :error -> s
      end
    end)
  end

  defp encode_default(value) when is_atom(value) and not is_boolean(value) and not is_nil(value),
    do: to_string(value)

  defp encode_default(value), do: value

  defp put_opt(schema, opts, key, json_key) do
    case Keyword.fetch(opts, key) do
      {:ok, value} -> Map.put(schema, json_key, value)
      :error -> schema
    end
  end

  # ── Cast plan ─────────────────────────────────────────────────────────────

  @doc """
  Compile `[%Field{}]` to a cast plan: instructions for converting validated
  string-keyed input into an atom-keyed map with defaults applied and enum
  values cast to atoms. Safe — only field names declared at compile time are
  atomized.
  """
  def to_cast_plan(fields) do
    Enum.map(fields, fn field ->
      %{
        key: to_string(field.name),
        name: field.name,
        type: cast_type(field),
        default: Keyword.get(field.opts, :default)
      }
    end)
  end

  defp cast_type(%Field{type: :enum, opts: opts}), do: {:enum, opts[:values]}
  defp cast_type(%Field{type: :object, children: children}), do: {:object, to_cast_plan(children)}

  defp cast_type(%Field{type: {:array, :object}, children: children}),
    do: {:array, {:object, to_cast_plan(children)}}

  defp cast_type(%Field{type: {:array, inner}}), do: {:array, inner}
  defp cast_type(%Field{type: type}), do: type

  @doc "Apply a cast plan to validated string-keyed arguments."
  def cast(plan, args) when is_list(plan) and is_map(args) do
    Enum.reduce(plan, %{}, fn entry, acc ->
      case Map.fetch(args, entry.key) do
        {:ok, value} ->
          Map.put(acc, entry.name, cast_value(entry.type, value))

        :error ->
          case entry.default do
            nil -> acc
            default -> Map.put(acc, entry.name, default)
          end
      end
    end)
  end

  defp cast_value({:enum, values}, value) do
    Enum.find(values, value, fn atom -> to_string(atom) == value end)
  end

  defp cast_value({:object, plan}, value) when is_map(value), do: cast(plan, value)

  defp cast_value({:array, inner}, value) when is_list(value),
    do: Enum.map(value, &cast_value(inner, &1))

  defp cast_value(_type, value), do: value
end
