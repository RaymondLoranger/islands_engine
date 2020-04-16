defmodule Islands.Engine.Server.AddPlayer do
  alias Islands.Engine.Server.Error
  alias Islands.Engine.Server
  alias Islands.{Game, Request, State}

  @spec handle_call(Request.t(), Server.from(), Game.t()) :: Server.reply()
  def handle_call(
        {:add_player = action, name, gender, pid} = request,
        _from,
        game
      ) do
    with {:ok, state} <- State.check(game.state, action),
         false <- name == game[:player1].name do
      game
      |> Game.update_player(:player2, name, gender, pid)
      |> Game.update_state(state)
      |> Game.update_request(request)
      |> Game.update_response({:ok, :player2_added})
      |> Game.notify_player(:player1)
      |> Server.save()
      |> Server.reply(:player2)
    else
      :error -> Error.reply(action, game, request, :player2)
      true -> Error.reply(:duplicate_player_name, game, request, :player2)
    end
  end
end
