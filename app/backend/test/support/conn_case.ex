defmodule DerobotWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest
      import DerobotWeb.ConnCase

      @endpoint DerobotWeb.Endpoint
    end
  end

  setup tags do
    Derobot.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
