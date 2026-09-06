defmodule NoizuPromptLingua.Protocols.ErpTest do
  @moduledoc """
  JSON/entity-reference protocol derivations in protocols/erp.ex.

  Behavior pins (verified against `EntityRepo.sref_handlers/0` — auth-provider,
  authz-group, authz-policy, invite-token, media-asset, membership, …):

    * For sref STRINGS ("ref.<kind>.<id>"), only `kind/1` resolves (to the
      entity module); `id/ref/sref` propagate `{:error, {:unsupported, …}}`
      from the handler — those operations are ref-tuple-shaped, not strings.
    * Unknown kinds propagate `{:error, {:handler_not_found, sref}}`.
    * `Jason.Encoder` for Tuple renders bare tuples as inspect output.

  Not covered by design: the 3-element-opts `encode/2` clauses — only
  invocable with hand-built Jason-internal opts tuples (the public Jason API
  always passes 2-tuples), and they crash in `Jason.Encode.string/2` if ever
  reached. Dead defensive branches.
  """
  use ExUnit.Case, async: true

  alias Noizu.EntityReference.Protocol, as: RefProtocol

  describe "Jason.Encoder for Tuple" do
    test "bare tuples encode as inspect output" do
      assert Jason.encode!({1, 2}) == ~s("{1, 2}")
      assert Jason.encode!(%{pair: {:a, :b}}) == ~s({"pair":"{:a, :b}"})
    end
  end

  describe "EntityReference.Protocol for BitString" do
    test "the repo registers sref handlers" do
      handlers = NoizuPromptLingua.EntityRepo.sref_handlers()

      assert is_map(handlers)
      assert handlers != %{}
    end

    test "kind/1 resolves a known kind to its entity module" do
      {kind, handler} = Enum.at(NoizuPromptLingua.EntityRepo.sref_handlers(), 0)

      assert {:ok, ^handler} = RefProtocol.kind("ref.#{kind}.#{Ecto.UUID.generate()}")
    end

    test "id/ref/sref on sref strings propagate the handler's :unsupported error" do
      {kind, _handler} = Enum.at(NoizuPromptLingua.EntityRepo.sref_handlers(), 0)
      sref = "ref.#{kind}.#{Ecto.UUID.generate()}"

      assert {:error, {:unsupported, _}} = RefProtocol.id(sref)
      assert {:error, {:unsupported, _}} = RefProtocol.ref(sref)
      assert {:error, {:unsupported, _}} = RefProtocol.sref(sref)
    end

    test "unknown kinds propagate handler_not_found" do
      assert {:error, {:handler_not_found, "ref.unknownkind.1234"}} =
               RefProtocol.id("ref.unknownkind.1234")

      assert {:error, {:handler_not_found, "ref.unknownkind.1234"}} =
               RefProtocol.kind("ref.unknownkind.1234")

      assert {:error, {:handler_not_found, _}} = RefProtocol.sref("ref.unknownkind.1234")
    end
  end
end
