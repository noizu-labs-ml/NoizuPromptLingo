defmodule Mix.Tasks.Nz.Gen.Entity do
  @moduledoc """
  mix nz.gen.entity Repo Entity schema --sref=reference --store=ecto --id=uuid --field=field_name:type
  use --no-live to prevent live view generation
  use --no-ecto to prevent context and entity generation
  """
  use Mix.Task

  @ecto_types [
    "integer",
    "float",
    "string",
    "boolean",
    "binary",
    "date",
    "time",
    "naive_datetime",
    "utc_datetime",
    "utc_datetime_usec",
    "uuid",
    "map",
    "array",
    "decimal",
    "json",
    "jsonb",
    "enum",
    "any"
  ]

  defp extract_args(argv) do
    OptionParser.parse(
      argv || [],
      switches: [
        app: :string,
        sref: :string,
        id: :string,
        store: :keep,
        live: :boolean,
        ecto: :boolean,
        field: :keep,
        meta: :keep,
        context: :boolean,
        schema: :boolean,
        context_app: :string,
        web: :string
      ]
    )
  end

  def run(args) do
    options = gen_options(args)
    check_files(options)
    setup_directories(options)

    ecto = is_nil(args[:ecto]) || args[:ecto]
    live = is_nil(args[:live]) || args[:live]

    ecto_gen_fields =
      if ecto || live do
        ecto_gen(options)
      end

    # Generate Context and Entity Files
    with {:ok, context_body} <- context_template(options),
         {:ok, entity_body} <- entity_template(options) do
      if Mix.Project.umbrella?(options.config) do
        cond do
          live ->
            app = :"#{options.app}_web"
            app_dir = "#{app}"

            optional_args =
              [
                options.args[:context_app] && "--context-app=#{options.args[:context_app]}",
                options.args[:web] && "--web=#{options.args[:web]}",
                options.args[:context] == false && "--no-context",
                options.args[:schema] == false && "--no-schema"
              ]
              |> Enum.filter(& &1)

            command =
              [
                "Schema.#{options.context.name}",
                options.entity.name,
                options.table.name | ecto_gen_fields
              ] ++ optional_args

            # Mix.Shell.cmd("mix app phx.gen.live #{Enum.join(command, " ")}", fn(x) -> IO.puts(x) end)
            Mix.Project.in_project(
              app,
              "#{options.config[:apps_path]}/#{app_dir}",
              fn module ->
                Mix.Shell.IO.info(
                  "Running: mix phx.gen.live in #{module} #{Enum.join(command, " ")}"
                )

                Mix.Shell.cmd("mix phx.gen.live #{Enum.join(command, " ")}", fn x ->
                  IO.puts(x)
                end)
              end
            )

          ecto ->
            optional_args =
              [
                options.args[:context] == false && "--no-context",
                options.args[:schema] == false && "--no-schema"
              ]
              |> Enum.filter(& &1)

            command =
              [
                "Schema.#{options.context.name}",
                options.entity.name,
                options.table.name | ecto_gen_fields
              ] ++ optional_args

            Mix.Project.in_project(
              options.app,
              "#{options.config[:apps_path]}/#{options.app}",
              fn module ->
                Mix.Shell.IO.info(
                  "Running: mix phx.gen.context in #{module} #{Enum.join(command, " ")}"
                )

                Mix.Shell.cmd("mix phx.gen.context #{Enum.join(command, " ")}", fn x ->
                  IO.puts(x)
                end)
              end
            )

          :else ->
            :nop
        end
      else
        cond do
          live ->
            optional_args =
              [
                options.args[:web] && "--web=#{options.args[:web]}",
                options.args[:context] == false && "--no-context",
                options.args[:schema] == false && "--no-schema"
              ]
              |> Enum.filter(& &1)

            command =
              [
                "Schema.#{options.context.name}",
                options.entity.name,
                options.table.name | ecto_gen_fields
              ] ++ optional_args

            Mix.Shell.IO.info("Running: mix phx.gen.live in #{Enum.join(command, " ")}")
            Mix.Shell.cmd("mix phx.gen.live #{Enum.join(command, " ")}", fn x -> IO.puts(x) end)

          ecto ->
            optional_args =
              [
                options.args[:context] == false && "--no-context",
                options.args[:schema] == false && "--no-schema"
              ]
              |> Enum.filter(& &1)

            command =
              [
                "Schema.#{options.context.name}",
                options.entity.name,
                options.table.name | ecto_gen_fields
              ] ++ optional_args

            Mix.Shell.IO.info("Running: mix phx.gen.live in #{Enum.join(command, " ")}")
            Mix.Shell.cmd("mix phx.gen.live #{Enum.join(command, " ")}", fn x -> IO.puts(x) end)

          :else ->
            :nop
        end
      end

      # Write Entity Files
      File.write(options.context.file, context_body)
      File.write(options.entity.file, entity_body)
    end
  end

  def ecto_gen(options) do
    meta = extract_meta(options)

    Keyword.get_values(options.args, :field)
      |> Enum.map(fn
        x ->
          case String.split(x, ":") do
            [field] ->
              # @TODO also check if meta attribute for ecto was set @ecto type: value
              # temp work around
              if t = meta[field] && get_in(meta[field], ["ecto.type"]) do
                "#{field}:#{t}"
              end

            [field | type] ->
              type = Enum.join(type, ":") |> String.trim()

              case type do
                "array:" <> _ ->
                  "#{field}:#{type}"

                "enum:" <> _ ->
                  "#{field}:#{type}"

                t when t in @ecto_types ->
                  "#{field}:#{type}"

                _ ->
                  try do
                    # @TODO also check if meta attribute for ecto was set @ecto type: value
                    # temp work around
                    if t = meta[field] && get_in(meta[field], ["ecto.type"]) do
                      "#{field}:#{t}"
                    else
                      m = String.to_existing_atom("Elixir.#{type}")

                      with {:ok, x} <- apply(m, :ecto_gen_string, [field]) do
                        x
                      else
                        _ -> nil
                      end
                    end
                  rescue
                    _ ->
                      Mix.Shell.IO.error("Failed to determine Type #{type} for field #{field}")
                      exit(1)
                  end
              end
          end
      end)
      |> List.flatten()
      |> Enum.filter(& &1)
  end

  def context_template(options) do
    author =
      cond do
        authors = options.config[:authors] -> Enum.join(authors, ", ")
        :else -> options.app_name
      end

    org = options.config[:organization] || options.app_name

    app = options.app_name
    context = options.context.name
    entity = options.entity.name
    x = entity |> String.replace(".", "")
    singular = Macro.underscore(Inflex.singularize(x))
    plural = Macro.underscore(Inflex.pluralize(x))
    entity_alias = "Entity"

    template = """
      #-------------------------------------------------------------------------------
      # Author: #{author}
      # Copyright (C) #{DateTime.utc_now().year} #{org} All rights reserved.
      #-------------------------------------------------------------------------------

      defmodule #{app}.#{context} do
        @moduledoc \"""
        Context for #{app}.#{context}.#{entity}
        \"""
        alias #{app}.#{context}.#{entity}, as: #{entity_alias}
        use Noizu.Repo
        def_repo()

        @doc \"""
        Returns the list of #{plural}.
        \"""
        def list_#{plural}(context, options \\\\ []) do
          # list(context)
          []
        end

        @doc \"""
        Gets a single #{singular}.

        \"""
        def get_#{singular}(id, context, options \\\\ []), do: get(id, context, options)

        @doc \"""
        Creates a #{singular}.
        \"""
        def create_#{singular}(#{singular}, context, options \\\\ []) do
          create(#{singular}, context, options)
        end

        @doc \"""
        Updates a #{singular}.
        \"""
        def update_#{singular}(%#{entity_alias}{} = #{singular}, attrs, context, options \\\\ []) do
          #{singular}
          |> change_#{singular}(attrs)
          |> update(context, options)
        end

        @doc \"""
        Deletes a #{singular}.
        \"""
        def delete_#{singular}(%#{entity_alias}{} = #{singular}, context, options \\\\ []) do
          delete(#{singular}, context, options)
        end

        @doc \"""
        Returns an Changeset for tracking #{singular} changes.
        \"""
        def change_#{singular}(%#{entity_alias}{} = #{singular}, attrs \\\\ %{}) do
          # NYI: Implement custom changeset logic here.
          #{singular}
        end
      end
    """

    {:ok, template}
  end

  def entity_template(options) do
    author =
      cond do
        authors = options.config[:authors] -> Enum.join(authors, ", ")
        :else -> options.app_name
      end

    org = options.config[:organization] || options.app_name
    app = options.app_name
    context = options.context.name
    entity = options.entity.name
    x = entity |> String.replace(".", "")
    #singular = Macro.underscore(Inflex.singularize(x))
    #plural = Macro.underscore(Inflex.pluralize(x))

    meta = extract_meta(options)
    {field_order, fields} = extract_fields(meta, options)
    stores = extract_stores(options)
    id_type = extract_id(options)
    sref = extract_sref(options)

    sref_block =
      cond do
        is_nil(sref) -> ""
        true -> "@sref \"#{sref}\""
      end

    persistence_block =
      cond do
        stores == [] ->
          nil

        is_list(stores) ->
          Enum.map_join(
            stores,
           "\n",
            fn
              store ->
                store =
                  store
                  |> indent(String.length("@persistence "))
                  |> String.trim_leading()

                "@persistence #{store}"
            end
          )
          
      end

    field_block =
      (field_order || [])
      |> Enum.map_join(
        "\n",
        fn
          field ->
            settings = fields[field]
            type = settings.type

            default =
              cond do
                default = settings.meta["default"] -> default
                :else -> "nil"
              end

            field_indent = String.duplicate(" ", String.length("field :#{field}, "))
            default_block = indent(default, field_indent) |> String.trim_leading()

            attribute_block =
              Enum.map(
                settings.meta || [],
                fn
                  {flag, _} when flag in ["default", "ecto.type"] ->
                    nil

                  {attribute, value} ->
                    value =
                      value
                      |> indent(String.length("@#{attribute} "))
                      |> String.trim_leading()

                    "@#{attribute} #{value}"
                end
              )
              |> Enum.reject(&is_nil/1)
              |> Enum.join("\n")

            type_indent =
              case String.split(default_block, "\n") do
                [x] ->
                  field_indent <> String.duplicate(" ", String.length(x) + String.length(", "))

                l when is_list(x) ->
                  x = List.last(l)
                  String.duplicate(" ", String.length(x) + String.length(", "))
              end

            type_block =
              case type do
                nil -> ""
                "array:" <> type -> ", {:array, :#{type}}"
                t when t in @ecto_types -> ", :#{t}"
                x -> ", " <> x
              end
              |> indent(type_indent)
              |> String.trim_leading()

            if attribute_block == "" do
              """
              field :#{field}, #{default}#{type_block}
              """
              |> String.trim()
            else
              """
              #{attribute_block}
              field :#{field}, #{default}#{type_block}
              """
              |> String.trim()
            end
        end
      )

    template = """
    #-------------------------------------------------------------------------------
    # Author: #{author}
    # Copyright (C) #{DateTime.utc_now().year} #{org} All rights reserved.
    #-------------------------------------------------------------------------------

    defmodule #{app}.#{context}.#{entity} do
      use Noizu.Entities

      @vsn 1.0
      @repo #{app}.#{context}
      #{sref_block}
      #{persistence_block && persistence_block |> indent("  ") |> String.trim_leading()}
      def_entity do
        id #{id_type}
        #{field_block |> indent("    ") |> String.trim_leading()}
      end
    end
    """

    {:ok, template}
  end

  def indent(string, indent \\ "  ")

  def indent(string, indent) when is_integer(indent) do
    indent(string, String.duplicate(" ", indent))
  end

  def indent(string, indent) do
    string
    |> String.split("\n")
    |> Enum.map_join("\n", fn x -> indent <> x end)
  end

  def dedent(string) do
    lines = String.split(string, "\n")
    first_line = Enum.at(lines, 0)
    dedent = String.length(first_line) - String.length(String.trim(first_line))
    strip = String.duplicate(" ", dedent)

    lines
    |> Enum.map_join("\n", &String.trim_leading(&1, strip))
  end

  def extract_sref(options) do
    cond do
      sref = options.args[:sref] -> sref
      :else -> nil
    end
  end

  def extract_id(options) do
    case options.args[:id] do
      "atom" -> ":atom"
      "uuid" -> ":uuid"
      "integer" -> ":integer"
      "ref" -> ":ref"
      "dual_ref" -> ":dual_ref"
      x when is_bitstring(x) -> x
      nil -> ":uuid"
    end
  end

  def extract_stores(options) do
    Keyword.get_values(options.args, :store)
    |> Enum.map(fn
      "ecto" -> "{:ecto, :storage}"
      "redis" -> "{:redis, :storage}"
      "amnesia" -> "{:amnesia, :storage}"
      "mnesia" -> "{:mnesia, :storage}"
      x when is_bitstring(x) -> x
    end)
  end

  def extract_fields(meta, options) do
    fields = Keyword.get_values(options.args, :field)

    order =
      fields
      |> Enum.map(fn
        x ->
          case String.split(x, ":") do
            [field] -> field
            [field | _] -> field
          end
      end)
      |> Enum.uniq()

    fields =
      fields
      |> Enum.map(fn
        x ->
          case String.split(x, ":") do
            [field] ->
              m = meta[field] || %{}
              {field, %{type: nil, meta: m}}

            [field | type] ->
              m = meta[field] || %{}
              type = Enum.join(type, ":") |> String.trim()

              type =
                case type do
                  "array:" <> t ->
                    "{:array, :#{t}}"

                  "enum:" <> values ->
                    values =
                      Enum.split(values, ":")
                      |> Enum.map_join(", ", &":#{String.trim(&1)}")
                    "{:enum, [#{values}]}"

                  t when t in @ecto_types ->
                    ":#{t}"

                  x ->
                    x
                end

              {field, %{type: type, meta: m}}
          end
      end)
      |> Map.new()

    {order, fields}
  end

  def extract_meta(options) do
    Keyword.get_values(options.args, :meta)
    |> Enum.map(fn
      x ->
        case String.split(x, ":") do
          [field | meta] ->
            meta = Enum.join(meta, ":")

            case String.split(meta, "=") do
              [k] -> {field, {k, "true"}}
              [k | v] -> {field, {k, Enum.join(v, "=")}}
            end
        end
    end)
    |> Enum.group_by(&elem(&1, 0))
    |> Enum.map(fn
      {field, x} ->
        v =
          x
          |> Enum.map(&elem(&1, 1))
          |> Map.new()

        {field, v}
    end)
    |> Map.new()
  end

  def usage do
    """
    mix nz.gen.entity Repo Entity schema --sref=reference --store=ecto --id=uuid --field=field_name:type --meta=field_name:opt --meta=field_name:opt=value
    use --no-live to prevent live view generation
    use --no-ecto to prevent context and entity generation
    """
  end

  def gen_options([context, entity, table | argv]) do
    Mix.Task.run("app.config", [])
    {args, params, errors} = extract_args(argv)

    unless errors == [] do
      Mix.Shell.IO.error("Invalid arguments: #{inspect(errors)}")
      Mix.Shell.IO.info(usage())
      exit(1)
    end

    unless params == [] do
      Mix.Shell.IO.error("Invalid arguments: #{inspect(params)}")
      Mix.Shell.IO.info(usage())
      exit(1)
    end

    config = Mix.Project.config()
    path = path(args, config)
    context_snake = Macro.underscore(context)
    context_file = "#{path}/entities/#{context_snake}.ex"
    entity_snake = Macro.underscore(entity)
    entity_file = "#{path}/entities/#{context_snake}/#{entity_snake}.ex"

    %{
      app_name: app_name(args, config),
      app: app_atom(args, config),
      args: args,
      config: config,
      path: path,
      context: %{name: context, snake: context_snake, file: context_file},
      entity: %{name: entity, snake: entity_snake, file: entity_file},
      table: %{name: table}
    }
  end

  defp setup_directories(options) do
    dir = String.split(options.entity.file, "/") |> Enum.slice(0..-2//1) |> Enum.join("/")
    File.mkdir_p(dir)
  end

  defp check_files(options) do
    if File.exists?(options.context.file) do
      Mix.Shell.IO.error("Context File Already Exists: #{options.context.file}")
      exit(1)
    end

    if File.exists?(options.entity.file) do
      Mix.Shell.IO.error("Entity File Already Exists: #{options.entity.file}")
      exit(1)
    end
  end

  defp path(args, config) do
    cond do
      Mix.Project.umbrella?(config) ->
        app_path = config[:apps_path] || "apps"

        if app = args[:app] do
          "#{app_path}/#{app}/lib/#{app}"
        else
          Mix.Shell.IO.error("--app argument required for umbrella project")
          exit(1)
        end

      app = config[:app] ->
        "lib/#{app}"
    end
  end

  defp app_atom(args, config) do
    cond do
      Mix.Project.umbrella?(config) -> String.to_atom(args[:app])
      app = config[:app] -> app
    end
  end

  defp app_name(args, config) do
    app_atom(args, config)
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map_join("", &String.capitalize(&1))
  end
end
