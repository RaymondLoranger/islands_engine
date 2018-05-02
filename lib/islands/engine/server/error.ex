defmodule Islands.Engine.Server.Error do
  @moduledoc false
  alias Islands.Engine.{Game, Server}

  require Logger

  @spec log(atom, any, any) :: :ok
  def log(:handle_call, non_matched_value, request) do
    """

    `handle_call` request:
    #{inspect(request, pretty: true)}

    `with` non-matched value:
    #{inspect(non_matched_value, pretty: true)}
    """
    |> Logger.error()
  end

  def log(:terminate, reason, game) do
    """

    `terminate` reason:
    #{inspect(reason)}

    `game` to clean up:
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
