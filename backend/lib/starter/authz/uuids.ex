defmodule Starter.Authz.UUIDs do
  @moduledoc false

  @app_namespace (
    hash = :crypto.hash(:sha, <<0x6B, 0xA7, 0xB8, 0x10, 0x9D, 0xAD, 0x11, 0xD1,
                                  0x80, 0xB4, 0x00, 0xC0, 0x4F, 0xD4, 0x30, 0xC8>> <> "starter-app.local")
    <<a::32, b::16, _::4, c::12, _::2, d::62, _rest::binary>> = hash
    <<a::32, b::16, 5::4, c::12, 2::2, d::62>>
  )

  # Template group UUIDs
  def group_owner, do: uuid5(@app_namespace, "group:owner")
  def group_admin, do: uuid5(@app_namespace, "group:admin")
  def group_member, do: uuid5(@app_namespace, "group:member")
  def group_viewer, do: uuid5(@app_namespace, "group:viewer")

  # System policy UUIDs
  def policy_super_admin, do: uuid5(@app_namespace, "policy:system:super-admin")
  def policy_owner, do: uuid5(@app_namespace, "policy:system:owner")
  def policy_admin, do: uuid5(@app_namespace, "policy:system:admin")
  def policy_member, do: uuid5(@app_namespace, "policy:system:member")
  def policy_viewer, do: uuid5(@app_namespace, "policy:system:viewer")

  @doc "Generate UUID v5 per RFC 4122 (SHA-1 based)"
  def uuid5(namespace, name) when is_binary(namespace) and is_binary(name) do
    hash = :crypto.hash(:sha, namespace <> name)
    <<a::32, b::16, _::4, c::12, _::2, d::62, _rest::binary>> = hash

    <<a::32, b::16, 5::4, c::12, 2::2, d::62>>
    |> encode_uuid()
  end

  defp encode_uuid(<<a::32, b::16, c::16, d::16, e::48>>) do
    [
      pad_hex(a, 8), "-",
      pad_hex(b, 4), "-",
      pad_hex(c, 4), "-",
      pad_hex(d, 4), "-",
      pad_hex(e, 12)
    ]
    |> IO.iodata_to_binary()
  end

  defp pad_hex(int, len) do
    hex = Integer.to_string(int, 16) |> String.downcase()
    String.pad_leading(hex, len, "0")
  end
end
