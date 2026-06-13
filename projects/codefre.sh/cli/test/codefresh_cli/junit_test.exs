defmodule CodefreshCli.JUnitTest do
  use ExUnit.Case, async: true

  alias CodefreshCli.JUnit

  test "renders testsuites/testsuite skeleton" do
    xml = JUnit.render(%{"script_slug" => "s1", "expectations" => []})
    assert xml =~ ~s(<?xml version="1.0")
    assert xml =~ "<testsuites"
    assert xml =~ ~s(<testsuite name="s1" tests="0")
  end

  test "failed expectation emits <failure>" do
    xml =
      JUnit.render(%{
        "script_slug" => "s1",
        "expectations" => [
          %{"label" => "ok", "status" => "pass"},
          %{"label" => "broken", "status" => "fail", "rationale" => "boom"}
        ]
      })

    assert xml =~ ~s(tests="2")
    assert xml =~ ~s(failures="1")
    assert xml =~ "<failure"
    assert xml =~ "boom"
  end

  test "warn becomes <skipped>" do
    xml =
      JUnit.render(%{
        "expectations" => [%{"label" => "flaky", "status" => "warn", "rationale" => "meh"}]
      })

    assert xml =~ "<skipped"
    assert xml =~ ~s(skipped="1")
  end

  test "escapes XML-special characters" do
    xml =
      JUnit.render(%{
        "expectations" => [
          %{"label" => "a&b<c>", "status" => "fail", "rationale" => ~s(bad "quote" <tag>)}
        ]
      })

    assert xml =~ "a&amp;b&lt;c&gt;"
    assert xml =~ "&quot;quote&quot;"
    refute xml =~ "<tag>"
  end

  test "tolerates steps+nested expectations" do
    xml =
      JUnit.render(%{
        "steps" => [
          %{"node_id" => "step-1", "expectations" => [%{"label" => "ok", "status" => "pass"}]}
        ]
      })

    assert xml =~ ~s(classname="step-1")
    assert xml =~ ~s(name="ok")
  end
end
