import Config

# case config_env() do
#   :dev ->
#     config :file_only_logger, log?: true
#     config :log_reset, levels: :all

#   :prod ->
#     config :file_only_logger, log?: true
#     config :log_reset, levels: :all

#   :test ->
#     config :file_only_logger, log?: true
#     config :log_reset, levels: :none

#   _ ->
#     config :file_only_logger, log?: true
#     config :log_reset, levels: :all
# end

# Supervisor option defaults for :max_restarts and :max_seconds...
{max_restarts, max_seconds} = {3, 5}
# 1.666 sec...
min_seconds_between_restarts = max_seconds / max_restarts
# 1,667 ms...
between_restarts = round(min_seconds_between_restarts * 1_000)
# 1,667 - 1,167 = 500 ms...
between_server_kills = between_restarts - 1_167
# 1,667 - 1 = 1,666 ms...
between_dyn_sup_kills = between_restarts - 1
# 1,667 + 999 = 2,666 ms...
between_sup_kills = between_restarts + 999
between_registration_checks = 10

# from = "➔ from #{Path.relative_to_cwd(__ENV__.file)}..."
# env = config_env()
# IO.puts("(#{env}) Between server kills: #{between_server_kills} ms #{from}")
# IO.puts("(#{env}) Between dyn sup kills: #{between_dyn_sup_kills} ms #{from}")
# IO.puts("(#{env}) Between sup kills: #{between_sup_kills} ms #{from}")

config :islands_engine,
  between_dyn_sup_kills: between_dyn_sup_kills,
  between_registration_checks: between_registration_checks,
  between_server_kills: between_server_kills,
  between_sup_kills: between_sup_kills
