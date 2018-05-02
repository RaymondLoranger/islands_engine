defmodule Islands.Engine.Server.Stop do
  @moduledoc false

  alias Islands.Engine.Server.Error
  alias Islands.Engine.{Game, Server, State}

  @spec handle_call(Server.request(), Server.from(), Game.t()) :: Server.reply()
  def handle_call({:stop = action, player_id} = request, _from, game) do
    with {:ok, state} <- State.check(game.state, action) do
      opponent_id = Game.opponent(player_id)

      game
      |> Game.update_state(state)
      |> Game.update_request(request)
      |> Game.update_response({:ok, :stopping})
      |> Game.notify_player(opponent_id)
      |> Server.save()
      |> Server.reply(player_id)
    else
      :error ->
        Error.reply(game, request, :not_both_players_islands_set, player_id)
    end
  end
end
