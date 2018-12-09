use Mix.Config

# Listed by ascending log level...
config :logger, :console,
  colors: [
    debug: :light_cyan,
    info: :light_green,
    warn: :light_yellow,
    error: :light_red
  ]

format = "$date $time [$level] $levelpad$message\n"

info_path = "./log/info.log"
warn_path = "./log/warn.log"
error_path = "./log/error.log"

config :logger, :console, format: format
config :logger, :info_log, format: format, path: info_path, level: :info
config :logger, :warn_log, format: format, path: warn_path, level: :warn
config :logger, :error_log, format: format, path: error_path, level: :error

config :logger,
  backends: [
    # :console,
    {LoggerFileBackend, :info_log},
    {LoggerFileBackend, :warn_log},
    {LoggerFileBackend, :error_log}
  ]

# Purges debug messages...
config :logger, compile_time_purge_level: :info

# Keeps only error messages...
# config :logger, compile_time_purge_level: :error

# Uncomment to stop logging...
# config :logger, level: :error

truncate_default_in_bytes = 8192

config :logger, truncate: truncate_default_in_bytes * 2
