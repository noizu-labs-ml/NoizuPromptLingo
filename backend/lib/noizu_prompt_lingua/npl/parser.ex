defmodule NoizuPromptLingua.NPL.Parser do
  @moduledoc false

  @sections ~w(syntax declarations directives prefixes prompt-sections special-sections pumps)
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

  @doc """
  Parse an expression. `section_aliases` (from `npl.yaml`'s `section_aliases`
  key, e.g. `%{"fences" => "prompt-sections"}`) map alternate section names to
  their canonical form; parsed additions/subtractions always carry the
  canonical section name.
  """
  @spec parse(String.t(), map()) :: {:ok, Expression.t()} | {:error, String.t()}
  def parse(expr, section_aliases \\ %{})

  def parse(expr, section_aliases) when is_binary(expr) do
    trimmed = String.trim(expr)
    aliases = normalize_aliases(section_aliases)

    if trimmed == "" do
      {:error, "Expression cannot be empty"}
    else
      trimmed
      |> String.split(~r/\s+/, trim: true)
      |> parse_terms([], [], aliases)
    end
  end

  defp normalize_aliases(aliases) when is_map(aliases) do
    Map.new(aliases, fn {k, v} -> {to_string(k), to_string(v)} end)
  end

  defp normalize_aliases(_), do: %{}

  defp parse_terms([], additions, subtractions, _aliases) do
    if additions == [] do
      {:error,
       "Expression must include at least one section to load. Cannot only have subtractions."}
    else
      {:ok,
       %Expression{additions: Enum.reverse(additions), subtractions: Enum.reverse(subtractions)}}
    end
  end

  defp parse_terms(["-" <> "" | _rest], _additions, _subtractions, _aliases) do
    {:error,
     "Invalid subtraction: '-' must be followed by a section reference. Example: -syntax#literal"}
  end

  defp parse_terms(["-" <> sub_term | rest], additions, subtractions, aliases) do
    case parse_section_ref(sub_term, aliases) do
      {:ok, component} -> parse_terms(rest, additions, [component | subtractions], aliases)
      {:error, _} = err -> err
    end
  end

  defp parse_terms([term | rest], additions, subtractions, aliases) do
    case parse_section_ref(term, aliases) do
      {:ok, component} -> parse_terms(rest, [component | additions], subtractions, aliases)
      {:error, _} = err -> err
    end
  end

  defp parse_section_ref(term, aliases) do
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
            case canonical_section(String.downcase(captures["section"]), aliases) do
              {:ok, section_name} ->
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

              :error ->
                {:error,
                 "Unknown section: '#{String.downcase(captures["section"])}'. Valid sections: #{@valid_sections}"}
            end
        end
    end
  end

  defp canonical_section(section, _aliases) when section in @sections, do: {:ok, section}

  defp canonical_section(section, aliases) do
    case Map.fetch(aliases, section) do
      {:ok, target} -> if target in @sections, do: {:ok, target}, else: :error
      :error -> :error
    end
  end

  defp parse_priority(""), do: {:ok, nil}
  defp parse_priority(nil), do: {:ok, nil}

  defp parse_priority("+" <> rest) do
    case Integer.parse(rest) do
      {n, ""} when n >= 0 ->
        {:ok, n}

      _ ->
        {:error,
         "Invalid priority format: '+#{rest}'. Priority must be a non-negative number. Example: syntax#placeholder:+2"}
    end
  end

  defp parse_priority(other) do
    {:error,
     "Invalid priority format: '#{other}'. Use :+N where N is a non-negative number. Example: syntax#placeholder:+2"}
  end
end
