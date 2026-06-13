defmodule Noizu.MCP.Types.Content do
  @moduledoc """
  An MCP content block: text, image, audio, resource link, or embedded resource.

  Build with the constructors:

      Content.text("hello")
      Content.image(binary, "image/png")
      Content.audio(binary, "audio/wav")
      Content.resource_link("file:///a.txt", name: "a.txt")
      Content.embedded_resource("config://app", text: "{}", mime_type: "application/json")
  """

  @type content_type :: :text | :image | :audio | :resource_link | :resource

  @type t :: %__MODULE__{
          type: content_type(),
          text: String.t() | nil,
          data: binary() | nil,
          mime_type: String.t() | nil,
          uri: String.t() | nil,
          name: String.t() | nil,
          title: String.t() | nil,
          description: String.t() | nil,
          resource: map() | nil,
          annotations: map() | nil,
          meta: map() | nil
        }

  defstruct [
    :type,
    :text,
    :data,
    :mime_type,
    :uri,
    :name,
    :title,
    :description,
    :resource,
    :annotations,
    :meta
  ]

  @spec text(String.t(), keyword()) :: t()
  def text(text, opts \\ []) when is_binary(text) do
    %__MODULE__{type: :text, text: text}
    |> apply_opts(opts)
  end

  @doc "Image content. `data` is the raw binary; it is base64-encoded on the wire."
  @spec image(binary(), String.t(), keyword()) :: t()
  def image(data, mime_type, opts \\ []) when is_binary(data) and is_binary(mime_type) do
    %__MODULE__{type: :image, data: data, mime_type: mime_type}
    |> apply_opts(opts)
  end

  @doc "Audio content. `data` is the raw binary; it is base64-encoded on the wire."
  @spec audio(binary(), String.t(), keyword()) :: t()
  def audio(data, mime_type, opts \\ []) when is_binary(data) and is_binary(mime_type) do
    %__MODULE__{type: :audio, data: data, mime_type: mime_type}
    |> apply_opts(opts)
  end

  @spec resource_link(String.t(), keyword()) :: t()
  def resource_link(uri, opts \\ []) when is_binary(uri) do
    %__MODULE__{type: :resource_link, uri: uri}
    |> apply_opts(opts)
  end

  @doc """
  Embedded resource content. Pass `text:` for text resources or `blob:` (raw
  binary, base64-encoded on the wire) for binary resources.
  """
  @spec embedded_resource(String.t(), keyword()) :: t()
  def embedded_resource(uri, opts \\ []) when is_binary(uri) do
    resource =
      %{"uri" => uri}
      |> put_unless_nil("mimeType", opts[:mime_type])
      |> put_unless_nil("text", opts[:text])
      |> put_unless_nil("blob", opts[:blob] && Base.encode64(opts[:blob]))

    %__MODULE__{type: :resource, resource: resource}
    |> apply_opts(Keyword.drop(opts, [:mime_type, :text, :blob]))
  end

  defp apply_opts(content, opts) do
    Enum.reduce(opts, content, fn
      {key, value}, acc
      when key in [:annotations, :meta, :name, :title, :description] ->
        Map.put(acc, key, value)

      {key, _}, _acc ->
        raise ArgumentError, "unknown content option: #{inspect(key)}"
    end)
  end

  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{type: :text} = c) do
    %{"type" => "text", "text" => c.text}
    |> common(c)
  end

  def to_map(%__MODULE__{type: type} = c) when type in [:image, :audio] do
    %{"type" => Atom.to_string(type), "data" => Base.encode64(c.data), "mimeType" => c.mime_type}
    |> common(c)
  end

  def to_map(%__MODULE__{type: :resource_link} = c) do
    %{"type" => "resource_link", "uri" => c.uri}
    |> put_unless_nil("name", c.name)
    |> put_unless_nil("title", c.title)
    |> put_unless_nil("description", c.description)
    |> put_unless_nil("mimeType", c.mime_type)
    |> common(c)
  end

  def to_map(%__MODULE__{type: :resource} = c) do
    %{"type" => "resource", "resource" => c.resource}
    |> common(c)
  end

  defp common(map, c) do
    map
    |> put_unless_nil("annotations", c.annotations)
    |> put_unless_nil("_meta", c.meta)
  end

  @spec from_map(map()) :: t()
  def from_map(%{"type" => "text"} = map) do
    %__MODULE__{
      type: :text,
      text: map["text"],
      annotations: map["annotations"],
      meta: map["_meta"]
    }
  end

  def from_map(%{"type" => type} = map) when type in ["image", "audio"] do
    %__MODULE__{
      type: String.to_existing_atom(type),
      data: decode_base64(map["data"]),
      mime_type: map["mimeType"],
      annotations: map["annotations"],
      meta: map["_meta"]
    }
  end

  def from_map(%{"type" => "resource_link"} = map) do
    %__MODULE__{
      type: :resource_link,
      uri: map["uri"],
      name: map["name"],
      title: map["title"],
      description: map["description"],
      mime_type: map["mimeType"],
      annotations: map["annotations"],
      meta: map["_meta"]
    }
  end

  def from_map(%{"type" => "resource"} = map) do
    %__MODULE__{
      type: :resource,
      resource: map["resource"],
      annotations: map["annotations"],
      meta: map["_meta"]
    }
  end

  defp decode_base64(nil), do: nil

  defp decode_base64(data) when is_binary(data) do
    case Base.decode64(data) do
      {:ok, decoded} -> decoded
      :error -> data
    end
  end

  defp put_unless_nil(map, _key, nil), do: map
  defp put_unless_nil(map, key, value), do: Map.put(map, key, value)
end
