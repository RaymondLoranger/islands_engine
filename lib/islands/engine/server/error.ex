defmodule Islands.Engine.Server.Error do
  alias Islands.Engine.Server
  alias Islands.{Game, PlayerID, Request}

  @spec reply(Game.t(), Request.t(), atom, PlayerID.t()) :: Server.reply()
  def reply(game, request, reason, player_id) do
    game
    |> Game.update_request(request)
    |> Game.update_response({:error, reason})
    |> Server.save()
    |> Server.reply(player_id)
  end
end
