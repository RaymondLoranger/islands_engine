defmodule Islands.Engine.GameServer.Stop do
  alias Islands.Engine.GameServer.ReplyTuple
  alias Islands.Engine.GameServer
  alias Islands.{Game, Request, State}

  @spec handle_call(Request.t(), GenServer.from(), Game.t()) :: ReplyTuple.t()
  def handle_call({action = :stop, player_id} = request, _from, game) do
    with {:ok, state} <- State.check(game.state, {action, player_id}) do
      opponent_id = Game.opponent_id(player_id)

      game
      |> Game.update_state(state)
      |> Game.update_request(request)
      |> Game.update_response({:ok, :stopping})
      |> Game.notify_player(opponent_id)
      |> GameServer.save()
      |> ReplyTuple.new(player_id)
    else
      :error -> ReplyTuple.new(action, game, request, player_id)
    end
  end
end
