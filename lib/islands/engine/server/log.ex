defmodule Islands.Engine.Server.Log do
  use File.Only.Logger

  alias Islands.Engine.Server

  error :handle_call, {non_matched_value, request, game} do
    """
    \n'with' non-matched value on 'handle_call'...
    • Server:
      #{game.name |> Server.via() |> inspect(pretty: true)}
    • Server PID: #{self() |> inspect(pretty: true)}
    • 'handle_call' request:
      #{inspect(request, pretty: true)}
    • 'with' non-matched value:
      #{inspect(non_matched_value, pretty: true)}
    • Game being processed:
      #{inspect(game, pretty: true)}
    #{from()}
    """
  end

  error :terminate, {reason, game} do
    """
    \nTerminating game...
    • Server:
      #{game.name |> Server.via() |> inspect(pretty: true)}
    • Server PID: #{self() |> inspect(pretty: true)}
    • 'handle_call' request:
      #{inspect(game.request, pretty: true)}
    • 'terminate' reason: #{inspect(reason, pretty: true)}
    • Game being terminated:
      #{inspect(game, pretty: true)}
    #{from()}
    """
  end

  info :terminate, {reason, game} do
    """
    \nTerminating game...
    • Server:
      #{game.name |> Server.via() |> inspect(pretty: true)}
    • Server PID: #{self() |> inspect(pretty: true)}
    • 'handle_call' request:
      #{inspect(game.request, pretty: true)}
    • 'terminate' reason: #{inspect(reason, pretty: true)}
    • Game being terminated:
      #{inspect(game, pretty: true)}
    #{from()}
    """
  end

  info :save, {game} do
    """
    \nSaving game...
    • Server:
      #{game.name |> Server.via() |> inspect(pretty: true)}
    • Server PID: #{self() |> inspect(pretty: true)}
    • 'handle_call' request:
      #{inspect(game.request, pretty: true)}
    • Game being saved:
      #{inspect(game, pretty: true)}
    #{from()}
    """
  end
end
