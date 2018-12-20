defmodule Islands.Engine.Proxy.Info do
  @moduledoc false

  use PersistConfig,
    files: ["config/dev.exs", "config/prod.exs", "config/test.exs"]

  require Logger

  @spec log(atom, tuple) :: :ok
  def log(event, details) do
    log? = Application.get_env(@app, :log?)
    do_log(event, details, log?)
  end

  ## Private functions

  @spec do_log(atom, tuple, boolean) :: :ok
  defp do_log(_event, _details, false = _log?), do: :ok

  defp do_log(:game_not_registered, details, true = _log?) do
    {game_name, timeout, times_left, reason} = details
    :ok = Logger.remove_backend(:console, flush: true)

    :ok =
      Logger.info("""
      \nGame #{inspect(game_name)} not registered:
      • Waiting: #{timeout} ms
      • Waits left: #{times_left}
      • Reason:
      #{inspect(reason)}
      """)

    {:ok, _pid} = Logger.add_backend(:console, flush: true)
    :ok
  end

  defp do_log(:game_registered, details, true = _log?) do
    {game_name, pid, times_left, reason} = details
    :ok = Logger.remove_backend(:console, flush: true)

    :ok =
      Logger.info("""
      \nGame #{inspect(game_name)} registered:
      • PID: #{inspect(pid)}
      • Waits left: #{times_left}
      • Reason:
      #{inspect(reason)}
      """)

    {:ok, _pid} = Logger.add_backend(:console, flush: true)
    :ok
  end
end
