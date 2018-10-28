defmodule Islands.Engine.Server.Error do
  @moduledoc false
  alias Islands.Engine.{Game, Server}

  require Logger

  @spec log(atom, any, any, any) :: :ok
  def log(:handle_call, non_matched_value, request, game) do
    """
    \n#{game.player1.name |> Server.via() |> inspect()} #{self() |> inspect()}
    `handle_call` request...
    #{inspect(request, pretty: true)}
    `with` non-matched value...
    #{inspect(non_matched_value, pretty: true)}
    game being processed...
    #{inspect(game, pretty: true)}
    """
    |> Logger.error()
  end

  @spec log(atom, any, any) :: :ok
  def log(:terminate, reason, game) do
    """
    \n#{game.player1.name |> Server.via() |> inspect()} #{self() |> inspect()}
    `handle_call` request...
    #{inspect(game.request, pretty: true)}
    `terminate` reason...
    #{inspect(reason, pretty: true)}
    game being terminated...
    #{inspect(game, pretty: true)}
    """
    |> Logger.error()
  end

  @spec reply(Game.t(), Server.request(), atom, Game.player_id()) ::
          Server.reply()
  def reply(game, request, reason, player_id) do
    game
    |> Game.update_request(request)
    |> Game.update_response({:error, reason})
    |> Server.save()
    |> Server.reply(player_id)
  end
end
