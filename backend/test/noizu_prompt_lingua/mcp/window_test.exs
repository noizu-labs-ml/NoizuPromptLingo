defmodule NoizuPromptLingua.MCP.WindowTest do
  use ExUnit.Case, async: true

  alias NoizuPromptLingua.MCP.Window

  @now DateTime.utc_now() |> DateTime.truncate(:second)

  test "empty entry: no window opinion" do
    assert Window.evaluate(%{}, @now) == {nil, nil}
    assert Window.evaluate(%{"hide_until" => nil}, @now) == {nil, nil}
  end

  test "hide_until in the future hides" do
    entry = %{"hide_until" => DateTime.add(@now, 3600, :second) |> DateTime.to_iso8601()}
    assert Window.evaluate(entry, @now) == {false, nil}
  end

  test "hide_until in the past is inert" do
    entry = %{"hide_until" => DateTime.add(@now, -3600, :second) |> DateTime.to_iso8601()}
    assert Window.evaluate(entry, @now) == {nil, nil}
  end

  test "hide_until accepts DateTime values" do
    entry = %{"hide_until" => DateTime.add(@now, 60, :second)}
    assert Window.evaluate(entry, @now) == {false, nil}
  end

  test "enable_for_hours: visible with expires_at until the window closes" do
    anchor = DateTime.add(@now, -3600, :second)

    entry = %{"enable_for_hours" => 24, "enable_from" => DateTime.to_iso8601(anchor)}
    assert {true, expires_at} = Window.evaluate(entry, @now)
    assert_in_delta DateTime.diff(expires_at, @now) / 3600, 23, 0.01

    expired = %{"enable_for_hours" => 24, "enable_from" => DateTime.to_iso8601(DateTime.add(@now, -25 * 3600, :second))}
    assert Window.evaluate(expired, @now) == {nil, nil}
  end

  test "enable_for_hours without an anchor is a permissive no-op" do
    assert Window.evaluate(%{"enable_for_hours" => 24}, @now) == {true, nil}
  end

  test "hide_until wins over enable_for_hours (mutually exclusive; hide takes precedence)" do
    entry = %{
      "hide_until" => DateTime.add(@now, 3600, :second) |> DateTime.to_iso8601(),
      "enable_for_hours" => 24,
      "enable_from" => DateTime.to_iso8601(DateTime.add(@now, -3600, :second))
    }

    assert Window.evaluate(entry, @now) == {false, nil}
  end

  test "garbage values are ignored" do
    assert Window.evaluate(%{"hide_until" => "not-a-date"}, @now) == {nil, nil}
    assert Window.evaluate(%{"enable_for_hours" => "soon"}, @now) == {nil, nil}
    assert Window.evaluate(nil, @now) == {nil, nil}
  end
end
