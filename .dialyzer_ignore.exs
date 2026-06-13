[
  # MapSet.t() is opaque; the struct default (MapSet.new()) in Peer's defstruct
  # makes dialyzer flag the constructor. Known dialyzer/struct-default noise.
  {"lib/noizu/mcp/peer.ex", :contract_with_opaque}
]
