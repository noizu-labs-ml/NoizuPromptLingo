defmodule OtelDisabledTest do
  @moduledoc """
  Regression test: with no OTEL_EXPORTER_OTLP_ENDPOINT the OpenTelemetry SDK
  must start disabled (no span processors, no exporters). Before the fix the
  default batch processor exported to http://localhost:4318 and retried
  forever, spamming deploy logs with failed_connect errors.
  """
  use ExUnit.Case, async: true

  test "SDK starts disabled when OTLP endpoint is unset" do
    assert Application.get_env(:opentelemetry, :sdk_disabled) == true
    assert :supervisor.which_children(:opentelemetry_sup) == []
  end
end
