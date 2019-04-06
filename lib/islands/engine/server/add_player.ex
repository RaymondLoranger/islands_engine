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
    with {:ok, state} <- State.check(game.state, action) do
      game
      |> Game.update_player_name(:player2, name)
      |> Game.update_player_gender(:player2, gender)
      |> Game.update_player_pid(:player2, pid)
      |> Game.update_state(state)
      |> Game.update_request(request)
      |> Game.update_response({:ok, :player2_added})
      |> Game.notify_player(:player1)
      |> Server.save()
      |> Server.reply(:player2)
    else
      :error ->
        Error.reply(game, request, :player2_already_added, :player2)
    end
  end
end
