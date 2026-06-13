defmodule CodefreshCli.ArgsTest do
  use ExUnit.Case, async: true

  alias CodefreshCli.Args

  @switches [
    agent: :string,
    persona: :string,
    threshold: :float,
    fail_on_warn: :boolean,
    format: :string,
    out: :string,
    org: :string,
    token: :string
  ]

  test "parses positional + flags" do
    assert {:ok, ["my-script"], flags} =
             Args.parse(
               ~w(my-script --agent openai-echo --persona novice --threshold 0.9),
               @switches
             )

    assert flags[:agent] == "openai-echo"
    assert flags[:persona] == "novice"
    assert flags[:threshold] == 0.9
  end

  test "boolean flag" do
    assert {:ok, [], flags} = Args.parse(~w(--fail-on-warn), @switches)
    assert flags[:fail_on_warn] == true
  end

  test "short alias -a expands to --agent" do
    assert {:ok, ["s"], flags} = Args.parse(~w(s -a my-agent), @switches)
    assert flags[:agent] == "my-agent"
  end

  test "returns :user error on unknown flag" do
    assert {:error, :user, msg} = Args.parse(~w(--bogus x), @switches)
    assert msg =~ "invalid flag"
  end
end
