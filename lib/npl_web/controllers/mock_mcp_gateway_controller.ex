defmodule NPLWeb.MockMCPGatewayController do
  use NPLWeb, :controller

  alias NPLWeb.Plugs.MockMCPGateway

  def handle(conn, %{"slug" => _slug} = _params) do
    MockMCPGateway.call(conn, [])
  end
end
