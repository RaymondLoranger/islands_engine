defmodule Islands.Engine.Proxy do
  @moduledoc """
  Runs function `GenServer.call` on behalf of module `Islands.Engine`
  while providing increased fault-tolerance capability.
  """

  alias __MODULE__.{Error, Info}
  alias Islands.Engine.Game.{Server, Tally}
  alias Islands.Engine

  @timeout 10
  @times 5

  @spec call(tuple, String.t(), tuple) :: Tally.t()
  def call(request, game_name, caller) do
    game_name |> Server.via() |> GenServer.call(request)
  catch
    :exit, reason ->
      Error.log(:exit, reason, caller)

      game_name
      |> wait(caller, @times)
      |> Server.via()
      |> GenServer.call(request)
  end

  @spec stop(atom, String.t(), tuple) :: :ok
  def stop(reason, game_name, caller) do
    game_name |> Server.via() |> GenServer.stop(reason)
  catch
    :exit, exit_reason ->
      Error.log(:exit, exit_reason, caller)

      game_name
      |> wait(caller, @times)
      |> Server.via()
      |> GenServer.stop(reason)
  end

  ## Private functions

  # On restarts, wait if name not yet registered...
  @spec wait(String.t(), tuple, non_neg_integer) :: String.t()
  defp wait(game_name, _caller, 0), do: game_name

  defp wait(game_name, caller, times_left) do
    Info.log(:game_not_registered, game_name, @timeout, times_left, caller)
    Process.sleep(@timeout)

    case Engine.game_pid(game_name) do
      pid when is_pid(pid) ->
        Info.log(:game_registered, game_name, pid, times_left, caller)
        game_name

      nil ->
        wait(game_name, caller, times_left - 1)
    end
  end
end
