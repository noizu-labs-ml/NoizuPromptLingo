defmodule CodefreshWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest
      import CodefreshWeb.ConnCase
      use CodefreshWeb, :verified_routes

      @endpoint CodefreshWeb.Endpoint
    end
  end

  setup tags do
    Codefresh.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
