defmodule NoizuPromptLingua.UUID do
  @moduledoc """
  The id-or-slug discriminator.

  Nearly every context here resolves a path segment, header or MCP tool argument
  that may be either a UUID or a human-friendly slug, and branches on which it
  is. Getting that branch wrong sends the query down the `id ==` path with a
  value that is really a slug, matches nothing, and returns not_found — a
  **404 on a record that exists**.

  ## Why `Ecto.UUID.cast/1` alone is wrong here

  `Ecto.UUID.cast/1` accepts two forms: the 36-character canonical string, and
  a **raw 16-byte binary**. That second form is the trap. Any 16-character slug
  is a 16-byte binary, so `cast/1` happily reinterprets its bytes as a UUID:

      iex> Ecto.UUID.cast("acme-corporation")
      {:ok, "61636d65-2d63-6f72-706f-726174696f6e"}

  Fifteen characters or seventeen are rejected; exactly sixteen is accepted. So
  a tenant whose slug happens to be sixteen characters long gets a 404 on their
  own records, and every other length works — which is why this survives
  review: it looks like a flake, not a bug.

  In this app the blast radius was the whole multi-tenant API.
  `Organizations.resolve_org_id/1` is the front door — the org slug is the
  primary URL segment, and `NoizuPromptLingua.MCP.Resolve.organization_id/1`
  funnels through it too. Its UUID branch passed the value straight through, so
  a 16-character org slug became the "organization UUID" for every downstream
  org-scoped query, and every one of them matched nothing.

  Refs arrive from a URL, a header or a tool argument, so the canonical string
  form is the only one a client can actually send. Requiring it costs nothing
  and closes the case.
  """

  @uuid_string_length 36

  @doc """
  True only for the 36-character canonical UUID string.

  Deliberately rejects the raw 16-byte binary form that `Ecto.UUID.cast/1`
  accepts — see the moduledoc.
  """
  @spec uuid?(term()) :: boolean()
  def uuid?(value) when is_binary(value) do
    byte_size(value) == @uuid_string_length and match?({:ok, _}, Ecto.UUID.cast(value))
  end

  def uuid?(_value), do: false

  @doc """
  `{:ok, uuid}` only for the 36-character canonical UUID string, `:error`
  otherwise. The `Ecto.UUID.cast/1` shape, with the raw-binary form rejected,
  so it is a drop-in replacement at any `case Ecto.UUID.cast(ref) do` site.
  """
  @spec cast(term()) :: {:ok, binary()} | :error
  def cast(value) do
    if uuid?(value), do: Ecto.UUID.cast(value), else: :error
  end
end
