defmodule Islands.Engine.Proxy do
  @moduledoc """
  Runs function `GenServer.call` on behalf of module `Islands.Engine`
  while providing increased fault-tolerance capability.
  """

  alias __MODULE__.{Error, GameNotStarted, Info}
  alias Islands.Engine.Game.{Server, Tally}
  alias Islands.Engine

  @timeout 10
  @times 5

  @spec call(tuple, String.t()) :: Tally.t() | :ok
  def call(request, game_name) do
    game_name |> Server.via() |> GenServer.call(request)
  catch
    :exit, reason ->
      Error.log(:exit, reason)

      case wait(game_name, reason, @times) do
        {:registered, game_name} ->
          game_name |> Server.via() |> GenServer.call(request)

        {:unregistered, game_name} ->
          Info.log(:game_not_started, game_name)
          game_name |> GameNotStarted.message() |> IO.puts()
      end
  end

  @spec stop(atom, String.t()) :: :ok
  def stop(reason, game_name) do
    game_name |> Server.via() |> GenServer.stop(reason)
  catch
    :exit, exit_reason ->
      Error.log(:exit, exit_reason)

      case wait(game_name, reason, @times) do
        {:registered, game_name} ->
          game_name |> Server.via() |> GenServer.stop(reason)

        {:unregistered, game_name} ->
          Info.log(:game_not_started, game_name)
          game_name |> GameNotStarted.message() |> IO.puts()
      end
  end

  ## Private functions

  # On restarts, wait if name not yet registered...
  @spec wait(String.t(), term, non_neg_integer) :: {atom, String.t()}
  defp wait(game_name, _reason, 0), do: {:unregistered, game_name}

  defp wait(game_name, reason, times_left) do
    Info.log(:game_not_registered, game_name, @timeout, times_left, reason)
    Process.sleep(@timeout)

    case Engine.game_pid(game_name) do
      pid when is_pid(pid) ->
        Info.log(:game_registered, game_name, pid, times_left, reason)
        {:registered, game_name}

      nil ->
        wait(game_name, reason, times_left - 1)
    end
  end
end
