# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2023 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.Entity.Macros.Json do
  @moduledoc """
  Macros for annotating json settings on entity fields.
  """
  require Noizu.Entity.Meta.Json
  require Noizu.Entity.Meta.Field

  # ----------------------------------------
  #
  # ----------------------------------------
  def register_attributes(mod) do
    Module.register_attribute(mod, :__nz_json, accumulate: true)
    Module.register_attribute(mod, :json, accumulate: true)
  end

  # ----------------------------------------
  #
  # ----------------------------------------
  def merge_json_settings([], _, _), do: []

  def merge_json_settings([h], template, field) do
    #    h = Noizu.Entity.Meta.Json.settings(h, template: template, field: field)
    #        |> Tuple.to_list()
    #        |> Enum.map(
    #             fn
    #               (:inherit) -> nil
    #               (x) -> x
    #             end)
    #        |> List.to_tuple()
    [Noizu.Entity.Meta.Json.json_settings(h, template: template, field: field)]
  end

  def merge_json_settings([a, b | t], template, field) do
    # IO.inspect(%{a: a, b: b}, label: "MERGE JSON")
    h =
      Enum.zip(Tuple.to_list(a), Tuple.to_list(b))
      |> Enum.map(fn
        {x, {:nz, :inherit}} -> x
        {{:nz, :inherit}, x} -> x
        {x, _} -> x
      end)
      |> List.to_tuple()

    merge_json_settings([h | t], template, field)
  end

  def expand_json_settings(json_list, fields) do
    # {:special, :json_template_specific2,
    #   [special: {:settings, :special, :json_template_specific2, :bop2, false, nil}]},
    #

    first_pass =
      json_list
      |> Enum.group_by(&elem(&1, 0))
      |> Enum.map(fn {k, v} ->
        x =
          v
          |> Enum.group_by(&elem(&1, 1))
          |> Enum.map(fn {k2, v2} ->
            v3 =
              Enum.map(v2, &elem(&1, 2))
              |> Enum.map(& &1)
              |> List.flatten()
              |> Noizu.Entity.Macros.Json.merge_json_settings(k, k2)

            # TODO merge
            {k2, v3}
          end)

        {k, x}
      end)

    core =
      Enum.map(fields, fn {field, r} ->
        omit =
          cond do
            Noizu.Entity.Meta.Field.field_settings(r, :transient) == true -> true
            field == :meta -> true
            :else -> false
          end

        {field,
         Noizu.Entity.Meta.Json.json_settings(template: :default, field: field, omit: omit)}
      end)

    {de, fp} = pop_in(first_pass, [:default])
    #    IO.inspect(de, label: "EXISTING DEFAULT")
    ud =
      Enum.map(core, fn {k, v} ->
        {k,
         Noizu.Entity.Macros.Json.merge_json_settings(
           [v | de[k] || []] |> Enum.reverse(),
           :default,
           k
         )}
      end)

    Enum.map(
      [{:default, ud} | fp],
      fn
        {k, v} ->
          v3 =
            Enum.map(
              ud,
              fn
                {k2, [v2]} ->
                  [x] =
                    Noizu.Entity.Macros.Json.merge_json_settings(
                      [v2 | v[k2] || []] |> Enum.reverse(),
                      k,
                      k2
                    )

                  {k2, x}
              end
            )
            |> List.flatten()
            |> Enum.filter(&(false == Noizu.Entity.Meta.Json.json_settings(elem(&1, 1), :omit)))

          unless v3 == [] do
            {k, v3 |> Map.new()}
          end
      end
    )
    |> Enum.filter(& &1)
    |> Map.new()
  end

  # ----------------------------------------
  #
  # ----------------------------------------
  def exact_json__settings(settings) do
    case settings do
      true ->
        [omit: false]

      :include ->
        [omit: false]

      false ->
        [omit: true]

      :omit ->
        [omit: true]

      {k, v2} when k in [true, false, :omit, :include] and is_list(v2) ->
        exact_json__settings(k) ++ exact_json__settings(v2)

      {k, v2} when k in [:omit, :include, :as] ->
        [{k, v2}]

      v when is_list(v) ->
        Enum.map(v, fn x -> exact_json__settings(x) end)
        |> List.flatten()
    end
  end

  defmacro extract_json(field) do
    quote bind_quoted: [field: field] do
      Module.get_attribute(__MODULE__, :json, [])
      |> Noizu.Entity.Macros.Json.extract_json__inner(field)
      #      |> tap(fn(x) ->
      #        unless x == %{} or x == [] or x == nil do
      #          Module.put_attribute(__MODULE__, :__nz_json, {field, x})
      #        end
      #      end)
      |> Enum.map(fn {template, values} ->
        Module.put_attribute(__MODULE__, :__nz_json, {template, field, values})
      end)

      Module.delete_attribute(__MODULE__, :json)
    end
  end

  def extract_json__inner(json, field) do
    json
    # |> IO.inspect(label: "EXTRACT JSON 0 (#{field})")
    |> Enum.map(fn entry ->
      {t, s} =
        case entry do
          v when is_atom(v) ->
            {:default, Noizu.Entity.Macros.Json.exact_json__settings(v)}

          [for: k, set: v] ->
            {k, Noizu.Entity.Macros.Json.exact_json__settings(v)}

          v = [{k, v2}] ->
            cond do
              is_list(k) ->
                {k, Noizu.Entity.Macros.Json.exact_json__settings(v2)}

              k in [:omit, :include, :as] ->
                {:default, Noizu.Entity.Macros.Json.exact_json__settings(v)}

              :else ->
                {k, Noizu.Entity.Macros.Json.exact_json__settings(v2)}
            end

          v when is_list(v) ->
            {:default, Noizu.Entity.Macros.Json.exact_json__settings(v)}

          v ->
            {:error, [{:error, v}]}
        end

      templates =
        cond do
          is_list(t) -> t
          :else -> [t]
        end

      s =
        s
        |> Enum.reduce(
          Noizu.Entity.Meta.Json.json_settings(template: nil, field: field),
          fn {k, v}, acc ->
            case k do
              :omit -> Noizu.Entity.Meta.Json.json_settings(acc, omit: v)
              :include -> Noizu.Entity.Meta.Json.json_settings(acc, omit: !v)
              :as -> Noizu.Entity.Meta.Json.json_settings(acc, as: v)
              :error -> Noizu.Entity.Meta.Json.json_settings(acc, error: v)
              _ -> acc
            end
          end
        )

      Enum.map(
        templates,
        fn template ->
          Noizu.Entity.Meta.Json.json_settings(s, template: template)
        end
      )
      |> Enum.map(fn json_entry ->
        template = Noizu.Entity.Meta.Json.json_settings(json_entry, :template)
        # field = Noizu.Entity.Meta.Json.json_settings(json_entry, :field)
        {template, json_entry}
      end)
    end)
    |> List.flatten()
    # |> IO.inspect(label: "EXTRACT JSON 1 (#{field})")
    |> Enum.group_by(&elem(&1, 0))
    |> Enum.map(fn {k, v} -> {k, Enum.map(v, &elem(&1, 1))} end)

    # |> IO.inspect(label: "EXTRACT JSON 2 (#{field})")
  end

  defmacro __extract_json__(field) do
    quote do
      json = Module.get_attribute(__MODULE__, :json, [])
      # IO.inspect(json, label: "JSON STACK: #{unquote(field)}")

      Enum.map(
        json,
        fn entry ->
          {t, s} =
            case entry do
              v when is_atom(v) ->
                {:default, Noizu.Entity.Macros.Json.exact_json__settings(v)}

              [for: k, set: v] ->
                {k, Noizu.Entity.Macros.Json.exact_json__settings(v)}

              [for: k, set: v] ->
                {k, Noizu.Entity.Macros.Json.exact_json__settings(v)}

              v = [{k, v2}] ->
                cond do
                  is_list(k) ->
                    {k, Noizu.Entity.Macros.Json.exact_json__settings(v2)}

                  k in [:omit, :include, :as] ->
                    {:default, Noizu.Entity.Macros.Json.exact_json__settings(v)}

                  :else ->
                    {k, Noizu.Entity.Macros.Json.exact_json__settings(v2)}
                end

              v when is_list(v) ->
                {:default, Noizu.Entity.Macros.Json.exact_json__settings(v)}

              v ->
                {:error, [{:error, v}]}
            end

          templates =
            cond do
              is_list(t) -> t
              :else -> [t]
            end

          s =
            s
            |> Enum.reduce(
              Noizu.Entity.Meta.Json.json_settings(template: nil, field: unquote(field)),
              fn {k, v}, acc ->
                case k do
                  :omit -> Noizu.Entity.Meta.Json.json_settings(acc, omit: v)
                  :include -> Noizu.Entity.Meta.Json.json_settings(acc, omit: !v)
                  :as -> Noizu.Entity.Meta.Json.json_settings(acc, as: v)
                  :error -> Noizu.Entity.Meta.Json.json_settings(acc, error: v)
                  _ -> acc
                end
              end
            )

          entries =
            Enum.map(
              templates,
              fn template ->
                Noizu.Entity.Meta.Json.json_settings(s, template: template)
              end
            )
            |> Enum.map(fn json_entry ->
              template = Noizu.Entity.Meta.Json.json_settings(json_entry, :template)
              field = Noizu.Entity.Meta.Json.json_settings(json_entry, :field)
              Module.put_attribute(__MODULE__, :__nz_json, {template, field, json_entry})
            end)

          # IO.inspect(entries, label: "Partial Process")
        end
      )

      Module.delete_attribute(__MODULE__, :json)
    end
  end
end
