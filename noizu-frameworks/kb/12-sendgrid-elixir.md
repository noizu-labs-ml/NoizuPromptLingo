# sendgrid_elixir (2.0.1)

SendGrid V3 API wrapper with composable email builder and Phoenix template support.

## Installation
```elixir
{:sendgrid, github: "Noizu/sendgrid_elixir"}
```

## Configuration
```elixir
config :sendgrid,
  api_key: "SG.xxx"
  # Optional:
  # sandbox_enable: true
  # phoenix_view: MyApp.EmailView
  # phoenix_layout: {MyApp.EmailView, :layout}
```

## Sending Email

```elixir
SendGrid.Email.build()
|> SendGrid.Email.add_to("recipient@example.com")
|> SendGrid.Email.put_from("sender@example.com")
|> SendGrid.Email.put_subject("Hello!")
|> SendGrid.Email.put_text("Plain text body")
|> SendGrid.Email.put_html("<h1>HTML body</h1>")
|> SendGrid.Mail.send()
# Returns :ok or {:error, reasons}
```

## Phoenix Templates
```elixir
SendGrid.Email.build()
|> SendGrid.Email.put_phoenix_view(MyApp.EmailView)
|> SendGrid.Email.put_phoenix_template("welcome.html", %{name: "Alice"})
|> SendGrid.Email.put_phoenix_layout({MyApp.LayoutView, "email.html"})
|> SendGrid.Mail.send()
```

## SendGrid Templates
```elixir
SendGrid.Email.build()
|> SendGrid.Email.put_template("d-abc123")
|> SendGrid.Email.add_substitution("-name-", "Alice")
|> SendGrid.Mail.send()
```

## Personalization (multiple recipients)
```elixir
p1 = SendGrid.Email.build() |> SendGrid.Email.add_to("user1@example.com") |> SendGrid.Email.to_personalization()
p2 = SendGrid.Email.build() |> SendGrid.Email.add_to("user2@example.com") |> SendGrid.Email.to_personalization()

SendGrid.Email.build()
|> SendGrid.Email.put_from("sender@example.com")
|> SendGrid.Email.add_personalization(p1)
|> SendGrid.Email.add_personalization(p2)
|> SendGrid.Mail.send()
```

## Other APIs
- `SendGrid.Templates.Templates` — Template management
- `SendGrid.MarketingCampaigns.Contacts.Lists` — Contact lists
- `SendGrid.MarketingCampaigns.Contacts.Recipients` — Bulk recipients

## Key Concepts
1. Composable pipeline pattern (build → configure → send)
2. Phoenix view/template integration for rich HTML emails
3. Tesla HTTP middleware (BaseUrl, JSON, Auth headers)
4. Sandbox mode for testing without sending
