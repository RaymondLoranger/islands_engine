# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# mix messages in colors
config :elixir, ansi_enabled: true

# Listed by ascending log level...
config :logger, :console,
  colors: [
    debug: :light_cyan,
    info: :light_green,
    warn: :light_yellow,
    error: :light_red
  ]

config :logger,
  backends: [
    # :console,
    {LoggerFileBackend, :info_log}
  ]

# Purges debug messages...
config :logger, compile_time_purge_level: :info

# Keeps only error messages...
# config :logger, compile_time_purge_level: :error

# Uncomment to stop logging...
# config :logger, level: :error

config :logger, :info_log,
  format: "$date $time [$level] $levelpad$message\n",
  path: File.cwd!() |> Path.join("log/info.log"),
  level: :info

#     import_config "#{Mix.env}.exs"
import_config "persist.exs"
