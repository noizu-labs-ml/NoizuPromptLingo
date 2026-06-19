# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     NoizuPromptLingua.Repo.insert!(%NoizuPromptLingua.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

require SeedHelper
import SeedHelper
SeedHelper.begin_session()

dir = Path.dirname(__ENV__.file)
Code.eval_file("#{dir}/seeds/#{Mix.env()}-seeds.exs")

# Will throw if any requires_seeds blocks were not resolved during execution.
:ok = end_session()
