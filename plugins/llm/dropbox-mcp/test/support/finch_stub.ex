defmodule DropboxMCP.Test.FinchStub do
  @moduledoc false

  def json(status, body) when is_map(body) or is_list(body) do
    {:ok,
     %Finch.Response{
       status: status,
       body: Jason.encode!(body),
       headers: [{"content-type", "application/json"}]
     }}
  end

  def json(status, nil) do
    {:ok, %Finch.Response{status: status, body: "null", headers: []}}
  end

  def download(meta, body) do
    {:ok,
     %Finch.Response{
       status: 200,
       body: body,
       headers: [
         {"dropbox-api-result", Jason.encode!(meta)},
         {"content-type", "application/octet-stream"}
       ]
     }}
  end
end
