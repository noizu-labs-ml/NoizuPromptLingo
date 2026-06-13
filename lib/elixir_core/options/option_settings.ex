# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.OptionSettings do
  alias Noizu.ElixirCore.OSP, as: OptionSettingProtocol

  @type t :: %__MODULE__{
          module: atom,
          option_settings: Map.t(),
          initial_options: Map.t(),
          effective_options: Map.t(),
          output: %{warnings: Map.t(), errors: Map.t()}
        }

  defstruct module: nil,
            option_settings: %{},
            initial_options: %{},
            effective_options: %{},
            output: %{warnings: %{}, errors: %{}}

  def expand(%__MODULE__{} = this, options \\ []) do
    this = %__MODULE__{this | initial_options: options}

    Enum.reduce(this.option_settings, this, fn {_option_name, option_definition}, acc ->
      OptionSettingProtocol.extract(option_definition, acc)
    end)
  end

  # end expand/2

  if Application.get_env(:noizu_scaffolding, :inspect_option_settings, true) do
    # -----------------------------------------------------------------------------
    # Inspect Protocol
    # -----------------------------------------------------------------------------
    defimpl Inspect, for: Noizu.ElixirCore.OptionSettings do
      import Inspect.Algebra

      def inspect(entity, opts) do
        heading = "#OptionSettings(#{entity.module})"
        {seperator, end_seperator} = if opts.pretty, do: {"\n   ", "\n"}, else: {" ", " "}

        inner =
          cond do
            opts.limit == :infinity ->
              concat(["<#{seperator}", to_doc(Map.from_struct(entity), opts), "#{end_seperator}>"])

            opts.limit >= 500 ->
              bare = %{
                option_settings: entity.option_settings,
                effective_options: entity.effective_options,
                initial_options: entity.initial_options,
                output: entity.output
              }

              concat(["<#{seperator}", to_doc(bare, opts), "#{end_seperator}>"])

            opts.limit >= 300 ->
              bare = %{
                option_settings: entity.option_settings,
                effective_options: entity.effective_options,
                initial_options: entity.initial_options
              }

              concat(["<#{seperator}", to_doc(bare, opts), "#{end_seperator}>"])

            opts.limit >= 200 ->
              bare = %{
                option_settings: entity.option_settings,
                effective_options: entity.effective_options
              }

              concat(["<#{seperator}", to_doc(bare, opts), "#{end_seperator}>"])

            opts.limit >= 100 ->
              bare = %{
                option_settings: entity.option_settings
              }

              concat(["<#{seperator}", to_doc(bare, opts), "#{end_seperator}>"])

            true ->
              "<>"
          end

        concat([heading, inner])
      end

      # end inspect/2
    end

    # end defimpl
  end
end
