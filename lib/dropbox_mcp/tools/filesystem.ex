defmodule DropboxMCP.Tools.Filesystem do
  @moduledoc """
  Dropbox filesystem tools exposed over MCP.

  Paths use Dropbox conventions: `""` or `"/"` is the account root
  (or `:default_root` / `DROPBOX_MCP_ROOT` when set); other paths are
  absolute (`"/folder/file.txt"`) and are jailed under that root.
  Mutating tools require `DROPBOX_MCP_WRITES=1`.
  """

  use Noizu.MCP.Server.Toolkit, category: "Dropbox Filesystem"

  alias DropboxMCP.Access
  alias DropboxMCP.Client
  alias DropboxMCP.Format
  alias Noizu.Dropbox.Api.Files
  alias Noizu.Dropbox.Api.Sharing
  alias Noizu.Dropbox.Api.Users
  alias Noizu.Dropbox.Struct.Metadata

  # ---------------------------------------------------------------------------
  # Read / list
  # ---------------------------------------------------------------------------

  @mcp name: "dropbox_list_folder",
       description:
         "List files and folders at a Dropbox path. Use empty path or / for the account root. Set recursive=true to walk the tree. Set all_pages=true to follow pagination.",
       annotations: [read_only_hint: true, idempotent_hint: true],
       input: [
         path: [type: :string, default: "", description: "Dropbox path (\"\" = root)"],
         recursive: [type: :boolean, default: false],
         all_pages: [
           type: :boolean,
           default: false,
           description: "If true, fetch all pages (may be slow on large folders)"
         ],
         include_deleted: [type: :boolean, default: false],
         limit: [type: :integer, min: 1, max: 2000, description: "Page size (Dropbox limit)"]
       ]
  def list_folder(args, _ctx) do
    read_path(args[:path], fn path ->
      client = Client.get()

      opts = [
        client: client,
        recursive: args[:recursive],
        include_deleted: args[:include_deleted]
      ]

      opts = if args[:limit], do: Keyword.put(opts, :limit, args[:limit]), else: opts

      result =
        if args[:all_pages] do
          Files.list_folder_all(path, opts)
        else
          Files.list_folder(path, opts)
        end

      case result do
        {:ok, listing} -> Format.ok_json(Format.list_folder(listing))
        {:error, err} -> Format.error(err)
      end
    end)
  end

  @mcp name: "dropbox_list_folder_continue",
       description: "Continue a previous dropbox_list_folder page using its cursor.",
       annotations: [read_only_hint: true, idempotent_hint: true],
       input: [
         cursor: [type: :string, required: true, description: "Cursor from a prior list_folder"]
       ]
  def list_folder_continue(%{cursor: cursor}, _ctx) do
    case Files.list_folder_continue(cursor, client: Client.get()) do
      {:ok, listing} -> Format.ok_json(Format.list_folder(listing))
      {:error, err} -> Format.error(err)
    end
  end

  @mcp name: "dropbox_get_metadata",
       description: "Get metadata for a file or folder at path.",
       annotations: [read_only_hint: true, idempotent_hint: true],
       input: [
         path: [type: :string, required: true, description: "Dropbox path"],
         include_deleted: [type: :boolean, default: false]
       ]
  def get_metadata(args, _ctx) do
    read_path(args[:path], fn path ->
      case Files.get_metadata(path,
             client: Client.get(),
             include_deleted: args[:include_deleted]
           ) do
        {:ok, meta} -> Format.ok_json(Format.metadata(meta))
        {:error, err} -> Format.error(err)
      end
    end)
  end

  @mcp name: "dropbox_read_file",
       description:
         "Download a file and return its contents as text (UTF-8). Binary/large files are truncated or base64 according to options.",
       annotations: [read_only_hint: true, idempotent_hint: true],
       input: [
         path: [type: :string, required: true, description: "File path"],
         encoding: [
           type: :enum,
           values: [:utf8, :base64],
           default: :utf8,
           description: "How to encode the body"
         ],
         max_bytes: [
           type: :integer,
           min: 1,
           description: "Max bytes to return (default from config)"
         ]
       ]
  def read_file(args, _ctx) do
    read_path(args[:path], fn path ->
      max_bytes =
        args[:max_bytes] || Application.get_env(:dropbox_mcp, :max_text_bytes, 1_000_000)

      case Files.download(path, client: Client.get()) do
        {:ok, %{metadata: meta, body: body}} ->
          size = byte_size(body)
          truncated? = size > max_bytes
          body = if truncated?, do: binary_part(body, 0, max_bytes), else: body

          content =
            case args[:encoding] do
              :base64 -> Base.encode64(body)
              _ -> safe_utf8(body)
            end

          Format.ok_json(%{
            "metadata" => Format.metadata(meta),
            "encoding" => to_string(args[:encoding] || :utf8),
            "truncated" => truncated?,
            "byte_size" => size,
            "content" => content
          })

        {:error, err} ->
          Format.error(err)
      end
    end)
  end

  @mcp name: "dropbox_search",
       description: "Full-text / filename search across Dropbox.",
       annotations: [read_only_hint: true, idempotent_hint: true],
       input: [
         query: [type: :string, required: true, min_length: 1, description: "Search query"],
         path: [type: :string, description: "Optional folder to scope the search"]
       ]
  def search(args, _ctx) do
    read_path(args[:path], fn path ->
      opts = [client: Client.get()]
      opts = if path == "", do: opts, else: Keyword.put(opts, :options, %{path: path})

      case Files.search_v2(args[:query], opts) do
        {:ok, result} -> Format.ok_json(result)
        {:error, err} -> Format.error(err)
      end
    end)
  end

  @mcp name: "dropbox_get_temporary_link",
       description: "Create a temporary direct-download link for a file (expires ~4 hours).",
       annotations: [read_only_hint: true],
       input: [
         path: [type: :string, required: true]
       ]
  def get_temporary_link(%{path: path}, _ctx) do
    read_path(path, fn path ->
      case Files.get_temporary_link(path, client: Client.get()) do
        {:ok, result} -> Format.ok_json(result)
        {:error, err} -> Format.error(err)
      end
    end)
  end

  # ---------------------------------------------------------------------------
  # Write / mutate
  # ---------------------------------------------------------------------------

  @mcp name: "dropbox_write_file",
       description:
         "Upload/create a file at path. Requires DROPBOX_MCP_WRITES=1. mode=overwrite replaces existing; mode=add fails if present (or autorename).",
       annotations: [destructive_hint: true, idempotent_hint: false],
       input: [
         path: [type: :string, required: true],
         content: [type: :string, required: true, description: "File body (text or base64)"],
         encoding: [
           type: :enum,
           values: [:utf8, :base64],
           default: :utf8
         ],
         mode: [
           type: :enum,
           values: [:add, :overwrite],
           default: :overwrite
         ],
         autorename: [type: :boolean, default: false]
       ]
  def write_file(args, _ctx) do
    write_path(args[:path], fn path ->
      data =
        case args[:encoding] do
          :base64 -> Base.decode64!(args[:content])
          _ -> args[:content]
        end

      mode =
        case args[:mode] do
          :add -> "add"
          _ -> "overwrite"
        end

      case Files.upload(path, data,
             client: Client.get(),
             mode: mode,
             autorename: args[:autorename] || false
           ) do
        {:ok, %Metadata{} = meta} -> Format.ok_json(Format.metadata(meta))
        {:ok, meta} -> Format.ok_json(Format.metadata(meta))
        {:error, err} -> Format.error(err)
      end
    end)
  end

  @mcp name: "dropbox_create_folder",
       description: "Create a folder at path. Requires DROPBOX_MCP_WRITES=1.",
       annotations: [destructive_hint: false, idempotent_hint: false],
       input: [
         path: [type: :string, required: true],
         autorename: [type: :boolean, default: false]
       ]
  def create_folder(args, _ctx) do
    write_path(args[:path], fn path ->
      case Files.create_folder_v2(path,
             client: Client.get(),
             autorename: args[:autorename] || false
           ) do
        {:ok, result} -> Format.ok_json(result)
        {:error, err} -> Format.error(err)
      end
    end)
  end

  @mcp name: "dropbox_move",
       description: "Move or rename a file/folder. Requires DROPBOX_MCP_WRITES=1.",
       annotations: [destructive_hint: true],
       input: [
         from_path: [type: :string, required: true],
         to_path: [type: :string, required: true],
         autorename: [type: :boolean, default: false]
       ]
  def move(args, _ctx) do
    write_paths(args[:from_path], args[:to_path], fn from, to ->
      case Files.move_v2(from, to, client: Client.get(), autorename: args[:autorename] || false) do
        {:ok, result} -> Format.ok_json(result)
        {:error, err} -> Format.error(err)
      end
    end)
  end

  @mcp name: "dropbox_copy",
       description: "Copy a file or folder. Requires DROPBOX_MCP_WRITES=1.",
       annotations: [destructive_hint: false],
       input: [
         from_path: [type: :string, required: true],
         to_path: [type: :string, required: true],
         autorename: [type: :boolean, default: false]
       ]
  def copy(args, _ctx) do
    write_paths(args[:from_path], args[:to_path], fn from, to ->
      case Files.copy_v2(from, to, client: Client.get(), autorename: args[:autorename] || false) do
        {:ok, result} -> Format.ok_json(result)
        {:error, err} -> Format.error(err)
      end
    end)
  end

  @mcp name: "dropbox_delete",
       description:
         "Delete a file or folder at path (moves to Dropbox trash when available). Requires DROPBOX_MCP_WRITES=1 and confirm=true.",
       annotations: [destructive_hint: true],
       input: [
         path: [type: :string, required: true],
         confirm: [
           type: :boolean,
           required: true,
           description: "Must be true to delete; refuses otherwise"
         ]
       ]
  def delete(args, _ctx) do
    if args[:confirm] != true do
      Format.error("confirm must be true to delete")
    else
      write_path(args[:path], fn path ->
        case Files.delete_v2(path, client: Client.get()) do
          {:ok, result} -> Format.ok_json(result)
          {:error, err} -> Format.error(err)
        end
      end)
    end
  end

  # ---------------------------------------------------------------------------
  # Sharing / account
  # ---------------------------------------------------------------------------

  @mcp name: "dropbox_create_shared_link",
       description: "Create a shared link for a path. Requires DROPBOX_MCP_WRITES=1.",
       annotations: [destructive_hint: false],
       input: [
         path: [type: :string, required: true]
       ]
  def create_shared_link(%{path: path}, _ctx) do
    write_path(path, fn path ->
      case Sharing.create_shared_link_with_settings(path, client: Client.get()) do
        {:ok, result} -> Format.ok_json(result)
        {:error, err} -> Format.error(err)
      end
    end)
  end

  @mcp name: "dropbox_list_shared_links",
       description: "List shared links, optionally filtered by path.",
       annotations: [read_only_hint: true, idempotent_hint: true],
       input: [
         path: [type: :string, description: "Optional path filter"],
         direct_only: [type: :boolean, default: false]
       ]
  def list_shared_links(args, _ctx) do
    read_path(args[:path], fn path ->
      opts = [client: Client.get(), direct_only: args[:direct_only] || false]
      opts = if path == "", do: opts, else: Keyword.put(opts, :path, path)

      case Sharing.list_shared_links(opts) do
        {:ok, result} -> Format.ok_json(result)
        {:error, err} -> Format.error(err)
      end
    end)
  end

  @mcp name: "dropbox_get_current_account",
       description: "Return the linked Dropbox account profile.",
       annotations: [read_only_hint: true, idempotent_hint: true]
  def get_current_account(_args, _ctx) do
    case Users.get_current_account(client: Client.get(), decode: :atoms) do
      {:ok, account} -> Format.ok_json(account)
      {:error, err} -> Format.error(err)
    end
  end

  @mcp name: "dropbox_get_space_usage",
       description: "Return space usage for the linked account.",
       annotations: [read_only_hint: true, idempotent_hint: true]
  def get_space_usage(_args, _ctx) do
    case Users.get_space_usage(client: Client.get(), decode: :atoms) do
      {:ok, usage} -> Format.ok_json(usage)
      {:error, err} -> Format.error(err)
    end
  end

  # ---------------------------------------------------------------------------

  defp read_path(path, fun) do
    case Access.jail_path(path) do
      {:ok, path} -> fun.(path)
      {:error, msg} -> Format.error(msg)
    end
  end

  defp write_path(path, fun) do
    with :ok <- Access.require_writes(),
         {:ok, path} <- Access.jail_path(path) do
      fun.(path)
    else
      {:error, msg} -> Format.error(msg)
    end
  end

  defp write_paths(from_path, to_path, fun) do
    with :ok <- Access.require_writes(),
         {:ok, from} <- Access.jail_path(from_path),
         {:ok, to} <- Access.jail_path(to_path) do
      fun.(from, to)
    else
      {:error, msg} -> Format.error(msg)
    end
  end

  defp safe_utf8(body) do
    case :unicode.characters_to_binary(body, :utf8, :utf8) do
      out when is_binary(out) ->
        out

      _ ->
        # Not valid UTF-8 — surface as base64 with a marker prefix
        "base64:" <> Base.encode64(body)
    end
  end
end
