defmodule Islands.Engine.Log do
  use File.Only.Logger

  alias Islands.Engine.Game.Server

  error :handle_call, {non_matched_value, request, game} do
    """
    \nServer #{game.name |> Server.via() |> inspect()} #{self() |> inspect()}:
    • 'handle_call' request:
    #{inspect(request, pretty: true)}
    • 'with' non-matched value:
    #{inspect(non_matched_value, pretty: true)}
    • game being processed:
    #{inspect(game, pretty: true)}
    """
  end

  error :terminate, {reason, game} do
    """
    \nServer #{game.name |> Server.via() |> inspect()} #{self() |> inspect()}:
    • 'handle_call' request:
    #{inspect(game.request, pretty: true)}
    • 'terminate' reason:
    #{inspect(reason, pretty: true)}
    • game being terminated:
    #{inspect(game, pretty: true)}
    """
  end

  info :terminate, {reason, game} do
    """
    \nServer #{game.name |> Server.via() |> inspect()} #{self() |> inspect()}:
    • 'handle_call' request:
    #{inspect(game.request, pretty: true)}
    • 'terminate' reason:
    #{inspect(reason, pretty: true)}
    • game being terminated:
    #{inspect(game, pretty: true)}
    """
  end

  info :save, {game} do
    """
    \nServer #{game.name |> Server.via() |> inspect()} #{self() |> inspect()}:
    • 'handle_call' request:
    #{inspect(game.request, pretty: true)}
    • game being saved:
    #{inspect(game, pretty: true)}
    """
  end
end
