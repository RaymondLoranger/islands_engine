defmodule Islands.Engine.Game.Server.Error do
  @moduledoc false

  alias Islands.Engine.Game.Server
  alias Islands.Engine.Game

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
