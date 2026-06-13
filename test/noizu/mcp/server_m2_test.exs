defmodule Noizu.MCP.ServerM2Test do
  @moduledoc "Integration tests for resources, templates, subscriptions, prompts, completion."
  use ExUnit.Case, async: true

  import Noizu.MCP.Test
  alias Noizu.MCP.Fixtures

  setup do
    %{client: connect(Fixtures.Server)}
  end

  describe "capabilities" do
    test "resources/prompts/completions are derived from registrations", %{client: client} do
      assert client.capabilities["resources"] == %{"listChanged" => true, "subscribe" => true}
      assert client.capabilities["prompts"] == %{"listChanged" => true}
      assert client.capabilities["completions"] == %{}
    end
  end

  describe "resources/list" do
    test "lists direct resources plus enumerable template instances", %{client: client} do
      assert {:ok, resources} = list_resources(client)
      uris = Enum.map(resources, & &1.uri)

      assert "config://app" in uris
      assert "asset://logo" in uris
      assert "db://users/schema" in uris
      assert "db://orders/schema" in uris
      assert length(resources) == 5
    end

    test "resource metadata flows through", %{client: client} do
      {:ok, resources} = list_resources(client)
      config = Enum.find(resources, &(&1.uri == "config://app"))

      assert config.name == "App Config"
      assert config.mime_type == "application/json"
      assert config.description == "Application configuration"
    end
  end

  describe "resources/templates/list" do
    test "lists templates", %{client: client} do
      assert {:ok, [template]} = list_resource_templates(client)
      assert template.uri_template == "db://{table}/schema"
      assert template.name == "Table Schema"
    end
  end

  describe "resources/read" do
    test "reads a direct text resource with its mime type", %{client: client} do
      assert {:ok, [contents]} = read_resource(client, "config://app")
      assert contents.uri == "config://app"
      assert contents.mime_type == "application/json"
      assert contents.text == ~s({"env":"test"})
      assert contents.blob == nil
    end

    test "reads a binary resource as base64 blob", %{client: client} do
      assert {:ok, [contents]} = read_resource(client, "asset://logo")
      assert contents.blob == <<137, 80, 78, 71>>
      assert contents.text == nil
    end

    test "reads through a template with extracted variables", %{client: client} do
      assert {:ok, [contents]} = read_resource(client, "db://users/schema")
      assert contents.text == ~s({"table":"users"})
    end

    test "unknown uri is resource_not_found (-32002)", %{client: client} do
      assert {:error, %{"code" => -32_002}} = read_resource(client, "nope://missing")
    end

    test "template handler can return resource_not_found", %{client: client} do
      assert {:error, %{"code" => -32_002}} = read_resource(client, "db://ghost/schema")
    end
  end

  describe "subscriptions" do
    test "subscribe → update → notification; unsubscribe stops them" do
      client = connect(Fixtures.Server)

      assert {:ok, %{}} = subscribe(client, "config://app")

      Fixtures.Server.notify_resource_updated("config://app")
      params = assert_notification(client, "notifications/resources/updated")
      assert params["uri"] == "config://app"

      assert {:ok, %{}} = unsubscribe(client, "config://app")
      Fixtures.Server.notify_resource_updated("config://app")
      refute_notification(client, "notifications/resources/updated")
    end

    test "updates only reach subscribed sessions" do
      subscribed = connect(Fixtures.Server)
      bystander = connect(Fixtures.Server)

      assert {:ok, %{}} = subscribe(subscribed, "config://app")
      Fixtures.Server.notify_resource_updated("config://app")

      assert_notification(subscribed, "notifications/resources/updated")
      refute_notification(bystander, "notifications/resources/updated")
    end

    test "non-subscribable resources reject subscribe", %{client: client} do
      assert {:error, %{"code" => -32_600}} = subscribe(client, "asset://logo")
    end

    test "unknown resources reject subscribe with resource_not_found", %{client: client} do
      assert {:error, %{"code" => -32_002}} = subscribe(client, "nope://missing")
    end
  end

  describe "prompts" do
    test "prompts/list with arguments", %{client: client} do
      assert {:ok, prompts} = list_prompts(client)
      assert length(prompts) == 2

      code_review = Enum.find(prompts, &(&1.name == "code_review"))
      assert code_review.description == "Review code for quality issues"

      [code_arg, style_arg] = code_review.arguments
      assert code_arg.name == "code"
      assert code_arg.required == true
      assert style_arg.name == "style"
      assert style_arg.required == false
    end

    test "prompts/get renders messages with the prompt description", %{client: client} do
      assert {:ok, result} = get_prompt(client, "code_review", %{"code" => "1 + 1"})

      assert result.description == "Review code for quality issues"
      assert [first, second] = result.messages
      assert first.role == :user
      assert first.content.text =~ "style: strict"
      assert second.content.text == "1 + 1"
    end

    test "explicit description from the handler wins", %{client: client} do
      assert {:ok, result} = get_prompt(client, "dynamic", %{"branch" => "main"})
      assert result.description == "dynamic description"
    end

    test "missing required arguments are invalid_params", %{client: client} do
      assert {:error, %{"code" => -32_602, "message" => message}} =
               get_prompt(client, "code_review", %{})

      assert message =~ "code"
    end

    test "unknown prompt is invalid_params", %{client: client} do
      assert {:error, %{"code" => -32_602}} = get_prompt(client, "nope", %{})
    end
  end

  describe "completion/complete" do
    test "static completion from arg complete: option, prefix-filtered", %{client: client} do
      assert {:ok, %{values: ["strict"]}} =
               complete(client, {:prompt, "code_review"}, "style", "st")

      assert {:ok, %{values: ["strict", "friendly"]}} =
               complete(client, {:prompt, "code_review"}, "style", "")
    end

    test "dynamic completion via complete/3 callback", %{client: client} do
      assert {:ok, %{values: ["feature/a", "feature/b"], has_more: false}} =
               complete(client, {:prompt, "dynamic"}, "branch", "feat")
    end

    test "resource template variable completion", %{client: client} do
      assert {:ok, %{values: values}} =
               complete(client, {:resource_template, "db://{table}/schema"}, "table", "or")

      assert values == ["orders", "order_items"]
    end

    test "unknown ref is invalid_params", %{client: client} do
      assert {:error, %{"code" => -32_602}} = complete(client, {:prompt, "nope"}, "x", "")

      assert {:error, %{"code" => -32_602}} =
               complete(client, {:resource_template, "x://{y}"}, "y", "")
    end

    test "unknown template variable is invalid_params", %{client: client} do
      assert {:error, %{"code" => -32_602}} =
               complete(client, {:resource_template, "db://{table}/schema"}, "nope", "")
    end
  end

  describe "list_changed for resources and prompts" do
    test "fan-out", %{client: client} do
      Fixtures.Server.notify_changed(:resources)
      assert_notification(client, "notifications/resources/list_changed")

      Fixtures.Server.notify_changed(:prompts)
      assert_notification(client, "notifications/prompts/list_changed")
    end
  end

  describe "servers without resources/prompts" do
    test "methods are method_not_found and capabilities absent" do
      client = connect(Fixtures.BareServer)

      refute Map.has_key?(client.capabilities, "resources")
      refute Map.has_key?(client.capabilities, "prompts")
      refute Map.has_key?(client.capabilities, "completions")

      assert {:error, %{"code" => -32_601}} = request(client, "resources/list")
      assert {:error, %{"code" => -32_601}} = request(client, "prompts/list")

      assert {:error, %{"code" => -32_601}} =
               request(client, "resources/subscribe", %{"uri" => "x"})

      assert {:error, %{"code" => -32_601}} = request(client, "completion/complete", %{})
    end
  end

  describe "uri template matching" do
    test "match, nomatch, decode" do
      assert {:ok, %{table: "users"}} =
               Noizu.MCP.UriTemplate.match("db://{table}/schema", "db://users/schema")

      assert :nomatch = Noizu.MCP.UriTemplate.match("db://{table}/schema", "db://users/data")
      assert :nomatch = Noizu.MCP.UriTemplate.match("db://{table}/schema", "db://a/b/schema")

      assert {:ok, %{owner: "acme", repo: "site"}} =
               Noizu.MCP.UriTemplate.match("gh://{owner}/{repo}", "gh://acme/site")

      assert {:ok, %{name: "hello world"}} =
               Noizu.MCP.UriTemplate.match("x://{name}", "x://hello%20world")
    end
  end
end
