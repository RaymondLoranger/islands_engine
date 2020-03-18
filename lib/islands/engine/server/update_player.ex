defmodule Islands.Engine.Server.UpdatePlayer do
  alias Islands.Engine.Server
  alias Islands.{Game, Request}

  @spec handle_call(Request.t(), Server.from(), Game.t()) :: Server.reply()
  def handle_call(
        {:update_player, player_id, name, gender, pid} = request,
        _from,
        game
      ) do
    game
    |> Game.update_player(player_id, name, gender, pid)
    |> Game.update_request(request)
    |> Game.update_response({:ok, :"#{player_id}_updated"})
    |> Server.save()
    |> Server.reply(player_id)
  end
end
