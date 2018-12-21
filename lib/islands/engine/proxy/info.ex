defmodule Islands.Engine.Proxy.Info do
  @moduledoc false

  use PersistConfig

  require Logger

  @log? Application.get_env(@app, :log?)

  @spec log(atom, tuple) :: :ok
  def log(event, details), do: do_log(event, details, @log?)

  ## Private functions

  @dialyzer {:nowarn_function, do_log: 3}
  @spec do_log(atom, tuple, boolean) :: :ok
  defp do_log(_event, _details, false = _log?), do: :ok

  defp do_log(:game_not_registered, details, true = _log?) do
    {game_name, timeout, times_left, reason} = details
    removed = Logger.remove_backend(:console, flush: true)

    Logger.info("""
    \nGame #{inspect(game_name)} not registered:
    • Waiting: #{timeout} ms
    • Waits left: #{times_left}
    • Reason:
    #{inspect(reason)}
    """)

    if removed == :ok, do: Logger.add_backend(:console, flush: true)
    :ok
  end

  defp do_log(:game_registered, details, true = _log?) do
    {game_name, pid, times_left, reason} = details
    removed = Logger.remove_backend(:console, flush: true)

    Logger.info("""
    \nGame #{inspect(game_name)} registered:
    • PID: #{inspect(pid)}
    • Waits left: #{times_left}
    • Reason:
    #{inspect(reason)}
    """)

    if removed == :ok, do: Logger.add_backend(:console, flush: true)
    :ok
  end
end
