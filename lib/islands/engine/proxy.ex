defmodule Islands.Engine.Proxy do
  @moduledoc """
  Runs function `GenServer.call` on behalf of module `Islands.Engine`
  while providing increased fault-tolerance capability.
  """

  alias Islands.Engine.Game.{Server, Tally}
  alias Islands.Engine

  require Logger

  @timeout_in_ms 10
  @times 100

  @spec call(tuple, String.t(), tuple) :: Tally.t()
  def call(request, game_name, caller) do
    game_name
    |> Server.via()
    |> GenServer.call(request)
  catch
    :exit, reason ->
      Logger.error("""
      \n`exit` caught for calling function #{inspect(caller)}...
      `exit` reason:
      #{inspect(reason)}
      """)

      game_name
      |> wait(caller, @times)
      |> Server.via()
      |> GenServer.call(request)
  end

  ## Private functions

  # On restarts, wait if name not yet registered...
  @spec wait(String.t(), tuple, non_neg_integer) :: String.t()
  defp wait(game_name, _caller, 0), do: game_name

  defp wait(game_name, caller, times_left) do
    Logger.info("""
    \nGame #{inspect(game_name)} not registered:
      • Waiting: #{@timeout_in_ms} ms
      • Waits left: #{times_left}
      • Calling function: #{inspect(caller)}
    """)

    Process.sleep(@timeout_in_ms)

    case Engine.game_pid(game_name) do
      pid when is_pid(pid) ->
        Logger.info("""
        \nGame #{inspect(game_name)} registered:
          • PID: #{inspect(pid)}
          • Waits left: #{times_left}
          • Calling function: #{inspect(caller)}
        """)

        game_name

      nil ->
        wait(game_name, caller, times_left - 1)
    end
  end
end
