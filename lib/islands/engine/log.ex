defmodule Islands.Engine.Log do
  use File.Only.Logger

  alias Islands.Engine.GameServer

  error :terminate, {reason, game, env} do
    """
    \nTerminating game...
    • Server: #{GameServer.via(game.name) |> inspect() |> maybe_break(10)}
    • Server PID: #{self() |> inspect()}
    • 'handle_call' request: #{inspect(game.request) |> maybe_break(25)}
    • 'terminate' reason: #{inspect(reason) |> maybe_break(22)}
    • Game being terminated: #{inspect(game) |> maybe_break(25)}
    #{from(env, __MODULE__)}
    """
  end

  info :terminate, {reason, game, env} do
    """
    \nTerminating game...
    • Server: #{GameServer.via(game.name) |> inspect() |> maybe_break(10)}
    • Server PID: #{self() |> inspect()}
    • 'handle_call' request: #{inspect(game.request) |> maybe_break(25)}
    • 'terminate' reason: #{inspect(reason) |> maybe_break(22)}
    • Game being terminated: #{inspect(game) |> maybe_break(25)}
    #{from(env, __MODULE__)}
    """
  end

  info :save, {game, env} do
    """
    \nSaving game...
    • Server: #{GameServer.via(game.name) |> inspect() |> maybe_break(10)}
    • Server PID: #{self() |> inspect()}
    • 'handle_call' request: #{inspect(game.request) |> maybe_break(25)}
    • Game being saved: #{inspect(game) |> maybe_break(20)}
    #{from(env, __MODULE__)}
    """
  end

  info :spawned, {game_name, player1_name, env} do
    """
    \nSpawned game server process...
    • Game name: #{game_name}
    • Player 1 name: #{player1_name}
    • Server PID: #{self() |> inspect()}
    #{from(env, __MODULE__)}
    """
  end

  info :restarted, {game_name, player1_name, env} do
    """
    \nRestarted game server process...
    • Game name: #{game_name}
    • Player 1 name: #{player1_name}
    • Server PID: #{self() |> inspect()}
    #{from(env, __MODULE__)}
    """
  end

  info :timeout, {timeout, game, env} do
    """
    \nGame server process timed out...
    • Game name: #{game.name}
    • Timeout: #{round(timeout / 1000 / 60)} min
    • Server PID: #{self() |> inspect()}
    #{from(env, __MODULE__)}
    """
  end
end
