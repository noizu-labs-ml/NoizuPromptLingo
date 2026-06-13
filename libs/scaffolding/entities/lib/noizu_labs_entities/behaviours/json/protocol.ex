# -------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2025 Noizu Labs Inc. All rights reserved.
# -------------------------------------------------------------------------------

defprotocol Noizu.Entity.Json.Protocol do
  @moduledoc """
  Define the Noizu.Entity.Json.Protocol used for preparing format style json responses.
  TODO https://github.com/noizu-labs-scaffolding/entities/issues/2
  """
  @fallback_to_any true
  @type restricted :: :"*restricted*"
  @type protocol_response ::
          {:error, any} | {:ok, any} | {:omit, any} | restricted | {restricted, any} | nil

  @spec prep(term :: term, settings :: term, context :: term, options :: term) ::
          protocol_response
  def prep(term, settings, context, options)

  @spec embed_field(
          value :: term,
          field_settings :: term,
          term :: term,
          term_settings :: term,
          context :: term,
          options :: term
        ) ::
          protocol_response
  def embed_field(value, field_settings, term, term_settings, context, options)
end

defimpl Noizu.Entity.Json.Protocol, for: [Any] do
  @moduledoc """
  Json Protocol Device
  """
  require Noizu.Entity.Meta.Json

  @restricted :"*restricted*"
  @type restricted :: :"*restricted*"
  @type protocol_response ::
          {:error, any} | {:ok, any} | {:omit, any} | restricted | {restricted, any} | nil

  @doc """
  Embed a field into the json response.
  """
  @spec embed_field(
          value :: term,
          field_settings :: term,
          term :: term,
          term_settings :: term,
          context :: term,
          options :: term
        ) ::
          protocol_response
  def embed_field(value, field_settings, term, term_settings, context, options)
  def embed_field(nil = value, _, _, _, _, _), do: {:omit, value}
  def embed_field(@restricted = value, _, _, _, _, _), do: {:omit, value}
  def embed_field({@restricted, _} = value, _, _, _, _, _), do: {:omit, value}
  def embed_field(value, _, _, _, _, _), do: {:ok, value}

  @doc """
  Prepares a json response,
    - Restricts fields based on ACL settings.
    - Prepare map after marking restricted fields.
  """
  @spec prep(term :: term, settings :: term, context :: term, options :: term) ::
          protocol_response
  def prep(term, settings, context, options)

  def prep(
        %{__struct__: m} = term,
        settings,
        context,
        options
      )
      when is_map(settings) do
    # Restrict Entity to ACL allowed view.
    with acl_config <- Noizu.Entity.Meta.acl(m),
         {:ok, restricted} <-
           Noizu.Entity.ACL.Protocol.restrict(:read, term, acl_config, context, options) do
      Enum.map(
          settings,
          fn
            # Cast id to sref string
            # TODO actually inspect to verify is id field type.
            {:id, _} ->
              with {:ok, sref} <- Noizu.EntityReference.Protocol.sref(term) do
                {:id, sref}
              else
                _ -> nil
              end

            # Grab field and json encodessettings and apply  prep recursively.
            {field, field_settings} ->
              with {:ok, v} <-
                     restricted
                     |> get_in([Access.key(field)])
                     |> Noizu.Entity.Json.Protocol.embed_field(
                       field_settings,
                       term,
                       settings,
                       context,
                       options
                     ),
                   {:ok, {f2, v2}} <-
                     Noizu.Entity.Json.Protocol.prep(v, field_settings, context, options) do
                {f2, v2}
              else
                nil ->
                  nil

                {:omit, _} ->
                  nil

                # todo tuple error handling
                {:error, x} ->
                  raise Noizu.Entity.Json.Exception, details: x
              end
          end
        )
        |> Enum.reject(&is_nil/1)
        |> Map.new()
    else
      # Omitted Field
      {:omit, _} ->
        nil

      # Restricted Field
      x = {@restricted, _} ->
        x

      # Restricted Value
      @restricted ->
        @restricted

      # Error
      {:error, x} ->
        raise Noizu.Entity.Json.Exception, details: x

      x ->
        raise Noizu.Entity.Json.Exception, details: {:other, x}
    end
  end

  def prep(term, Noizu.Entity.Meta.Json.json_settings(field: f), _, _), do: {:ok, {f, term}}
end
