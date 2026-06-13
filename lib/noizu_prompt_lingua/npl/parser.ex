defmodule NoizuPromptLingua.NPL.Parser do
  @moduledoc false

  @sections ~w(syntax declarations directives prefixes prompt-sections special-sections pumps fences)
  @section_set MapSet.new(@sections)
  @valid_sections Enum.sort(@sections) |> Enum.join(", ")

  @section_ref_regex ~r/^(?P<section>[a-z][a-z0-9-]*)(?:#(?P<component>[a-z][a-z0-9-]*))?(?::(?P<priority>\+?\-?[0-9]+|\+[a-z]+))?$/

  defmodule Component do
    @moduledoc false
    defstruct [:section, :component, :priority_max]

    @type t :: %__MODULE__{
            section: String.t(),
            component: String.t() | nil,
            priority_max: non_neg_integer() | nil
          }
  end

  defmodule Expression do
    @moduledoc false
    defstruct additions: [], subtractions: []

    @type t :: %__MODULE__{
            additions: [NoizuPromptLingua.NPL.Parser.Component.t()],
            subtractions: [NoizuPromptLingua.NPL.Parser.Component.t()]
          }
  end

  @spec parse(String.t()) :: {:ok, Expression.t()} | {:error, String.t()}
  def parse(expr) when is_binary(expr) do
    trimmed = String.trim(expr)

    if trimmed == "" do
      {:error, "Expression cannot be empty"}
    else
      trimmed
      |> String.split(~r/\s+/, trim: true)
      |> parse_terms([], [])
    end
  end

  defp parse_terms([], additions, subtractions) do
    if additions == [] do
      {:error, "Expression must include at least one section to load. Cannot only have subtractions."}
    else
      {:ok, %Expression{additions: Enum.reverse(additions), subtractions: Enum.reverse(subtractions)}}
    end
  end

  defp parse_terms(["-" <> "" | _rest], _additions, _subtractions) do
    {:error, "Invalid subtraction: '-' must be followed by a section reference. Example: -syntax#literal"}
  end

  defp parse_terms(["-" <> sub_term | rest], additions, subtractions) do
    case parse_section_ref(sub_term) do
      {:ok, component} -> parse_terms(rest, additions, [component | subtractions])
      {:error, _} = err -> err
    end
  end

  defp parse_terms([term | rest], additions, subtractions) do
    case parse_section_ref(term) do
      {:ok, component} -> parse_terms(rest, [component | additions], subtractions)
      {:error, _} = err -> err
    end
  end

  defp parse_section_ref(term) do
    cond do
      String.contains?(term, "@") ->
        {:error,
         "Invalid expression: '#{term}'. Use '#' to separate section from component, not '@'. Example: syntax#placeholder"}

      String.contains?(term, "::") ->
        {:error,
         "Invalid expression: '#{term}'. Found '::' - use single ':' for priority. Example: syntax#placeholder:+2"}

      true ->
        case Regex.named_captures(@section_ref_regex, term) do
          nil ->
            {:error,
             "Invalid expression: '#{term}'. Expected format: section[#component][:+N]. Example: syntax#placeholder:+2"}

          captures ->
            section_name = String.downcase(captures["section"])

            if not MapSet.member?(@section_set, section_name) do
              {:error, "Unknown section: '#{section_name}'. Valid sections: #{@valid_sections}"}
            else
              component = if captures["component"] == "", do: nil, else: captures["component"]

              case parse_priority(captures["priority"]) do
                {:ok, priority_max} ->
                  {:ok,
                   %Component{
                     section: section_name,
                     component: component,
                     priority_max: priority_max
                   }}

                {:error, _} = err ->
                  err
              end
            end
        end
    end
  end

  defp parse_priority(""), do: {:ok, nil}
  defp parse_priority(nil), do: {:ok, nil}

  defp parse_priority("+" <> rest) do
    case Integer.parse(rest) do
      {n, ""} when n >= 0 -> {:ok, n}
      _ -> {:error, "Invalid priority format: '+#{rest}'. Priority must be a non-negative number. Example: syntax#placeholder:+2"}
    end
  end

  defp parse_priority(other) do
    {:error,
     "Invalid priority format: '#{other}'. Use :+N where N is a non-negative number. Example: syntax#placeholder:+2"}
  end
end
