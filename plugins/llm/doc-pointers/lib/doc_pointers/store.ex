defmodule DocPointers.Store do
  use GenServer

  alias DocPointers.Pointer

  def start_link(opts) do
    root = Keyword.fetch!(opts, :root)
    GenServer.start_link(__MODULE__, root, name: __MODULE__)
  end

  def set_root(root), do: GenServer.call(__MODULE__, {:set_root, root})
  def get(uuid), do: GenServer.call(__MODULE__, {:get, uuid})
  def get_by_token(token), do: GenServer.call(__MODULE__, {:get_by_token, token})
  def put(pointer), do: GenServer.call(__MODULE__, {:put, pointer})
  def update(uuid, updates), do: GenServer.call(__MODULE__, {:update, uuid, updates})
  def all, do: GenServer.call(__MODULE__, :all)
  def token_exists?(token), do: GenServer.call(__MODULE__, {:token_exists?, token})

  def list(opts \\ []) do
    GenServer.call(__MODULE__, {:list, opts})
  end

  # -- Server --

  @impl true
  def init(root) do
    submodules = detect_submodules(root)

    state = %{
      root: root,
      submodules: submodules,
      pointers: %{},
      token_index: %{},
      store_membership: %{}
    }

    state = load_all_pointers(state)
    {:ok, state}
  end

  @impl true
  def handle_call({:set_root, root}, _from, state) do
    submodules = detect_submodules(root)

    state = %{
      state
      | root: root,
        submodules: submodules,
        pointers: %{},
        token_index: %{},
        store_membership: %{}
    }

    state = load_all_pointers(state)
    {:reply, :ok, state}
  end

  def handle_call({:get, uuid}, _from, state) do
    {:reply, Map.get(state.pointers, uuid), state}
  end

  def handle_call({:get_by_token, token}, _from, state) do
    case Map.get(state.token_index, token) do
      nil -> {:reply, nil, state}
      uuid -> {:reply, Map.get(state.pointers, uuid), state}
    end
  end

  def handle_call({:put, %Pointer{} = pointer}, _from, state) do
    {store_key, adjusted} = resolve_and_adjust(state, pointer)
    state = put_pointer(state, adjusted, store_key)
    save_store(state, store_key)
    {:reply, :ok, state}
  end

  def handle_call({:update, uuid, updates}, _from, state) do
    case Map.get(state.pointers, uuid) do
      nil ->
        {:reply, {:error, :not_found}, state}

      pointer ->
        now = DateTime.utc_now() |> DateTime.to_iso8601()
        store_key = Map.get(state.store_membership, uuid, "")

        updated =
          pointer
          |> maybe_update(:description, updates)
          |> maybe_update(:class, updates)
          |> maybe_update(:line, updates)
          |> maybe_update(:file_path, updates)
          |> Map.put(:updated_at, now)

        state = put_pointer(state, updated, store_key)
        save_store(state, store_key)
        {:reply, {:ok, updated}, state}
    end
  end

  def handle_call(:all, _from, state) do
    {:reply, Map.values(state.pointers), state}
  end

  def handle_call({:token_exists?, token}, _from, state) do
    {:reply, Map.has_key?(state.token_index, token), state}
  end

  def handle_call({:list, opts}, _from, state) do
    pointers =
      state.pointers
      |> Map.values()
      |> maybe_filter_prefix(opts[:file_prefix])
      |> maybe_filter_class(opts[:class])
      |> Enum.sort_by(& &1.created_at)

    offset = opts[:offset] || 0
    limit = opts[:limit] || 50

    result = pointers |> Enum.drop(offset) |> Enum.take(limit)
    {:reply, {result, length(pointers)}, state}
  end

  # -- Submodule detection --

  defp detect_submodules(root) do
    gitmodules_path = Path.join(root, ".gitmodules")

    if File.exists?(gitmodules_path) do
      gitmodules_path
      |> File.read!()
      |> parse_gitmodules()
      |> Enum.sort_by(&byte_size/1, :desc)
    else
      []
    end
  end

  defp parse_gitmodules(content) do
    Regex.scan(~r/path\s*=\s*(.+)/, content)
    |> Enum.map(fn [_, path] -> String.trim(path) end)
  end

  defp resolve_store_key(submodules, file_path) when is_binary(file_path) do
    Enum.find(submodules, "", fn sub_path ->
      String.starts_with?(file_path, sub_path <> "/")
    end)
  end

  defp resolve_store_key(_submodules, _), do: ""

  defp resolve_and_adjust(state, %Pointer{} = pointer) do
    store_key = resolve_store_key(state.submodules, pointer.file_path)

    adjusted =
      if store_key != "" and pointer.file_path do
        prefix = store_key <> "/"
        %{pointer | file_path: String.replace_prefix(pointer.file_path, prefix, "")}
      else
        pointer
      end

    {store_key, adjusted}
  end

  # -- Internals --

  defp put_pointer(state, %Pointer{} = pointer, store_key) do
    %{
      state
      | pointers: Map.put(state.pointers, pointer.uuid, pointer),
        token_index: Map.put(state.token_index, pointer.token, pointer.uuid),
        store_membership: Map.put(state.store_membership, pointer.uuid, store_key)
    }
  end

  defp maybe_update(pointer, field, updates) do
    case Map.get(updates, field) do
      nil -> pointer
      value -> Map.put(pointer, field, value)
    end
  end

  defp maybe_filter_prefix(pointers, nil), do: pointers

  defp maybe_filter_prefix(pointers, prefix) do
    Enum.filter(pointers, fn p -> p.file_path && String.starts_with?(p.file_path, prefix) end)
  end

  defp maybe_filter_class(pointers, nil), do: pointers

  defp maybe_filter_class(pointers, class) do
    Enum.filter(pointers, fn p -> p.class == class end)
  end

  defp store_root(state, ""), do: state.root
  defp store_root(state, store_key), do: Path.join(state.root, store_key)

  defp meta_dir(state, store_key), do: Path.join(store_root(state, store_key), ".meta")
  defp pointers_path(state, store_key), do: Path.join(meta_dir(state, store_key), "pointers.yaml")
  defp legacy_json_path(state), do: Path.join([state.root, "docs", "doc-pointer-db.json"])

  defp load_all_pointers(state) do
    store_keys = ["" | state.submodules]

    state =
      Enum.reduce(store_keys, state, fn store_key, acc ->
        path = pointers_path(acc, store_key)

        if File.exists?(path) do
          load_from_yaml(acc, store_key, path)
        else
          acc
        end
      end)

    maybe_load_legacy(state)
  end

  defp load_from_yaml(state, store_key, path) do
    case YamlElixir.read_from_file(path) do
      {:ok, %{"pointers" => pointers}} when is_map(pointers) ->
        Enum.reduce(pointers, state, fn {uuid, data}, acc ->
          pointer = Pointer.from_map(uuid, data)
          put_pointer(acc, pointer, store_key)
        end)

      _ ->
        state
    end
  end

  defp maybe_load_legacy(state) do
    legacy = legacy_json_path(state)

    if map_size(state.pointers) == 0 and File.exists?(legacy) do
      state = import_legacy_json(state)
      save_store(state, "")
      state
    else
      state
    end
  end

  defp import_legacy_json(state) do
    case File.read(legacy_json_path(state)) do
      {:ok, content} ->
        case Jason.decode(content) do
          {:ok, entries} when is_map(entries) ->
            Enum.reduce(entries, state, fn {token, data}, acc ->
              name = DocPointers.UUID5.build_name(data["name"] || token)
              uuid_bytes = DocPointers.UUID5.generate(name)
              uuid = DocPointers.UUID5.to_string(uuid_bytes)

              pointer =
                Pointer.new(%{
                  uuid: uuid,
                  token: token,
                  file_path: data["path"],
                  function: data["name"] || "unknown",
                  description: data["description"] || "",
                  line: data["line"]
                })

              put_pointer(acc, pointer, "")
            end)

          _ ->
            state
        end

      _ ->
        state
    end
  end

  defp save_store(state, store_key) do
    dir = meta_dir(state, store_key)
    File.mkdir_p!(dir)

    store_pointers =
      state.store_membership
      |> Enum.filter(fn {_uuid, sk} -> sk == store_key end)
      |> Enum.map(fn {uuid, _} -> {uuid, state.pointers[uuid]} end)
      |> Enum.reject(fn {_, p} -> is_nil(p) end)
      |> Enum.sort_by(fn {uuid, _} -> uuid end)
      |> Enum.map(fn {uuid, pointer} -> {uuid, Pointer.to_map(pointer)} end)
      |> Map.new()

    content = Ymlr.document!(%{"pointers" => store_pointers})
    File.write!(pointers_path(state, store_key), content)
  end
end
