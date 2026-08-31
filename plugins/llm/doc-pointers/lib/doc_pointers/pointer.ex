defmodule DocPointers.Pointer do
  @enforce_keys [:uuid, :token, :function, :description]
  defstruct [
    :uuid,
    :token,
    :file_path,
    :class,
    :function,
    :line,
    :description,
    :created_at,
    :updated_at
  ]

  @type t :: %__MODULE__{
          uuid: String.t(),
          token: String.t(),
          file_path: String.t() | nil,
          class: String.t() | nil,
          function: String.t(),
          line: non_neg_integer() | nil,
          description: String.t(),
          created_at: String.t() | nil,
          updated_at: String.t() | nil
        }

  def new(attrs) when is_map(attrs) do
    now = DateTime.utc_now() |> DateTime.to_iso8601()

    %__MODULE__{
      uuid: Map.fetch!(attrs, :uuid),
      token: Map.fetch!(attrs, :token),
      file_path: Map.get(attrs, :file_path),
      class: Map.get(attrs, :class),
      function: Map.fetch!(attrs, :function),
      line: Map.get(attrs, :line),
      description: Map.fetch!(attrs, :description),
      created_at: Map.get(attrs, :created_at, now),
      updated_at: Map.get(attrs, :updated_at, now)
    }
  end

  def to_map(%__MODULE__{} = p) do
    %{
      "token" => p.token,
      "function" => p.function,
      "file_path" => p.file_path,
      "class" => p.class,
      "line" => p.line,
      "description" => p.description,
      "created_at" => p.created_at,
      "updated_at" => p.updated_at
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  def from_map(uuid, map) when is_binary(uuid) and is_map(map) do
    %__MODULE__{
      uuid: uuid,
      token: map["token"],
      file_path: map["file_path"],
      class: map["class"],
      function: map["function"],
      line: map["line"],
      description: map["description"],
      created_at: map["created_at"],
      updated_at: map["updated_at"]
    }
  end
end
