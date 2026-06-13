defmodule Noizu.MCP.Server.Features.Pagination do
  @moduledoc false
  # Opaque offset cursors for list endpoints over compile-time registries.

  alias Noizu.MCP.Error

  @default_page_size 50

  def default_page_size, do: @default_page_size

  @doc "Slice `items` at `cursor`; returns `{:ok, page, next_cursor} | {:error, Error.t()}`."
  def paginate(items, cursor, page_size \\ @default_page_size) do
    case decode_cursor(cursor) do
      :error ->
        {:error, Error.invalid_params("Invalid cursor")}

      offset ->
        page = Enum.slice(items, offset, page_size)

        next_cursor =
          if offset + page_size < length(items),
            do: encode_cursor(offset + page_size),
            else: nil

        {:ok, page, next_cursor}
    end
  end

  defp encode_cursor(offset), do: Base.url_encode64("o:#{offset}", padding: false)

  defp decode_cursor(nil), do: 0

  defp decode_cursor(cursor) when is_binary(cursor) do
    with {:ok, "o:" <> offset} <- Base.url_decode64(cursor, padding: false),
         {offset, ""} <- Integer.parse(offset) do
      offset
    else
      _ -> :error
    end
  end

  defp decode_cursor(_), do: :error
end
