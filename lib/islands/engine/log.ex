defmodule Islands.Engine.Log do
  use File.Only.Logger

  alias Islands.Engine.GameServer

  error :terminate, {reason, game} do
    """
    \nTerminating game...
    • Server:
      #{GameServer.via(game.name) |> inspect()}
    • Server PID: #{self() |> inspect()}
    • 'handle_call' request:
      #{inspect(game.request)}
    • 'terminate' reason: #{inspect(reason)}
    • Game being terminated:
      #{inspect(game)}
    #{from()}
    """
  end

  info :terminate, {reason, game} do
    """
    \nTerminating game...
    • Server:
      #{GameServer.via(game.name) |> inspect()}
    • Server PID: #{self() |> inspect()}
    • 'handle_call' request:
      #{inspect(game.request)}
    • 'terminate' reason: #{inspect(reason)}
    • Game being terminated:
      #{inspect(game)}
    #{from()}
    """
  end

  info :save, {game} do
    """
    \nSaving game...
    • Server:
      #{GameServer.via(game.name) |> inspect()}
    • Server PID: #{self() |> inspect()}
    • 'handle_call' request:
      #{inspect(game.request)}
    • Game being saved:
      #{inspect(game)}
    #{from()}
    """
  end

  info :spawned, {game_name, player1_name} do
    """
    \nSpawned game server process...
    • Game name: #{game_name}
    • Player 1 name: #{player1_name}
    • Server PID: #{self() |> inspect()}
    #{from()}
    """
  end

  info :restarted, {game_name, player1_name} do
    """
    \nRestarted game server process...
    • Game name: #{game_name}
    • Player 1 name: #{player1_name}
    • Server PID: #{self() |> inspect()}
    #{from()}
    """
  end
end
