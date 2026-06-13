# -------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule Noizu.ElixirCore.OptionValue do
  @type t :: %__MODULE__{
          option: atom,
          lookup_key: atom,
          required: boolean,
          default: [atom] | nil,
          valid_values: [any] | :any
        }

  defstruct option: nil,
            lookup_key: nil,
            required: false,
            default: nil,
            valid_values: :any

  defimpl Noizu.ElixirCore.OSP, for: Noizu.ElixirCore.OptionValue do
    alias Noizu.ElixirCore.OptionSettings

    def extract(this, %OptionSettings{} = o) do
      key = this.lookup_key || this.option

      if Keyword.has_key?(o.initial_options, key) do
        arg = o.initial_options[key]

        if this.valid_values == :any do
          %OptionSettings{o | effective_options: Map.put(o.effective_options, this.option, arg)}
        else
          if Enum.member?(this.valid_values, arg) do
            %OptionSettings{o | effective_options: Map.put(o.effective_options, this.option, arg)}
          else
            %OptionSettings{
              o
              | effective_options: Map.put(o.effective_options, this.option, arg),
                output: %{
                  o.output
                  | errors: Map.put(o.output.errors, this.option, {:unsupported_value, arg})
                }
            }
          end
        end

        # ebd if valid_values
      else
        if this.required do
          %OptionSettings{
            o
            | output: %{
                o.output
                | errors: Map.put(o.output.errors, this.option, :required_option_missing)
              }
          }
        else
          %OptionSettings{
            o
            | effective_options: Map.put(o.effective_options, this.option, this.default)
          }
        end
      end

      # end has_key
    end

    # end def extract
  end

  # end defimple

  if Application.get_env(:noizu_scaffolding, :inspect_option_value, true) do
    # -----------------------------------------------------------------------------
    # Inspect Protocol
    # -----------------------------------------------------------------------------
    defimpl Inspect, for: Noizu.ElixirCore.OptionValue do
      import Inspect.Algebra

      def inspect(entity, opts) do
        req = (entity.required && ",required") || ""
        heading = "#OptionList(#{entity.option}#{req})"
        {seperator, end_seperator} = if opts.pretty, do: {"\n   ", "\n"}, else: {" ", " "}

        inner =
          cond do
            opts.limit == :infinity ->
              concat(["<#{seperator}", to_doc(Map.from_struct(entity), opts), "#{end_seperator}>"])

            opts.limit >= 200 ->
              bare = %{
                lookup_key: entity.lookup_key,
                default: entity.default,
                valid_values: entity.valid_values
              }

              concat(["<#{seperator}", to_doc(bare, opts), "#{end_seperator}>"])

            opts.limit >= 100 ->
              bare = %{
                default: entity.default
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

# end defmodule
