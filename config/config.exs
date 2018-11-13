# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# Mix messages in colors...
config :elixir, ansi_enabled: true

# Listed by ascending log level...
config :logger, :console,
  colors: [
    debug: :light_cyan,
    info: :light_green,
    warn: :light_yellow,
    error: :light_red
  ]

format = "$date $time [$level] $levelpad$message\n"

error_path = "./log/error.log"
info_path = "./log/info.log"

config :logger, :console, format: format
config :logger, :error_log, format: format, path: error_path, level: :error
config :logger, :info_log, format: format, path: info_path, level: :info

config :logger,
  backends: [
    # :console,
    {LoggerFileBackend, :error_log},
    {LoggerFileBackend, :info_log}
  ]

# Purges debug messages...
config :logger, compile_time_purge_level: :info

# Keeps only error messages...
# config :logger, compile_time_purge_level: :error

# Uncomment to stop logging...
# config :logger, level: :error

truncate_default_in_bytes = 8192

config :logger, truncate: truncate_default_in_bytes * 2

#     import_config "#{Mix.env}.exs"
import_config "persist.exs"
import_config "persist_book_ref.exs"
