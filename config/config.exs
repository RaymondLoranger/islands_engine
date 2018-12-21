# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# Mix messages in colors...
config :elixir, ansi_enabled: true

import_config "persist.#{Mix.env()}.exs"
import_config "config_*.exs"
import_config "persist_*.exs"
