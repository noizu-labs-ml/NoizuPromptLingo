defmodule Noizu.Core.Helpers do
  @moduledoc false

  # -------------------------
  # banner_text
  # -------------------------
  @doc """
    Verify response is a {:ok, value} tuple and return value or throw result exception
  """
  @spec ok?(any, any) :: any
  def ok?(result, requirement \\ :required)
  def ok?({:ok, v}, _), do: v

  def ok?({:error, _} = result, requirement),
    do: raise(Noizu.Core.ResultException, result: result, requirement: requirement)

  def ok?(result, requirement),
    do:
      raise(Noizu.Core.ResultException,
        result: {:error, {:invalid_tuple, result}},
        requirement: requirement
      )

  # -------------------------
  # banner_text
  # -------------------------
  @doc """
  Prepare banner string output.
  """
  @spec banner_text(any, any) :: any
  @spec banner_text(any, any, any) :: any
  @spec banner_text(any, any, any, any) :: any
  def banner_text(header, msg, len \\ 120, pad \\ 0) do
    header_len = String.length(header)
    h_len = div(len, 2)

    sub_len = div(header_len, 2)
    rem = rem(header_len, 2)

    l_len = h_len - sub_len
    r_len = h_len - sub_len - rem

    char = "*"

    lines = String.split(msg, "\n", trim: true)

    pad_str =
      cond do
        pad == 0 -> ""
        :else -> String.duplicate(" ", pad)
      end

    top =
      "\n#{pad_str}#{String.duplicate(char, l_len)} #{header} #{String.duplicate(char, r_len)}"

    bottom = pad_str <> String.duplicate(char, len) <> "\n"

    middle =
      for line <- lines do
        "#{pad_str}#{char} " <> line
      end

    middle = Enum.join(middle, "\n")

    "#{top}\n#{middle}\n#{bottom}"
  end
end
