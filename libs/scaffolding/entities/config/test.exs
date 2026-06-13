# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :noizu_labs_entities,
  legacy_mode: false,
  uid_provider: Noizu.Entity.Test.UIDProvider

config :junit_formatter,
  report_file: "results.xml",
  print_report_file: true
