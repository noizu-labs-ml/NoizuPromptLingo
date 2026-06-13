# codefresh_sdk — Elixir SDK

Elixir client for the [CodeFresh](https://codefre.sh) eval platform.

## Install

```elixir
def deps do
  [{:codefresh_sdk, "~> 0.1"}]
end
```

## Usage

```elixir
client = CodefreshSdk.new(token: "cf_...", api_url: "https://api.codefre.sh")

{:ok, runs} = CodefreshSdk.Runs.list(client, organization_id: org_id)
```

### Webhook signatures

```elixir
signature = get_req_header(conn, "x-codefresh-signature") |> List.first()

case CodefreshSdk.verify_webhook_signature(secret, body, signature) do
  :ok -> handle_event(Jason.decode!(body))
  {:error, :invalid_signature} -> send_resp(conn, 401, "")
end
```
