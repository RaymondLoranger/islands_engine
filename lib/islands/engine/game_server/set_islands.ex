defmodule Islands.Engine.GameServer.SetIslands do
  alias Islands.Engine.GameServer.ReplyTuple
  alias Islands.Engine.GameServer
  alias Islands.{Board, Game, Request, State}

  @spec handle_call(Request.t(), GenServer.from(), Game.t()) :: ReplyTuple.t()
  def handle_call({action = :set_islands, player_id} = request, _from, game) do
    with {:ok, state} <- State.check(game.state, {action, player_id}),
         %Board{} = board <- Game.player_board(game, player_id),
         true <- Board.all_islands_positioned?(board) do
      opponent_id = Game.opponent_id(player_id)

      game
      |> Game.update_state(state)
      |> Game.update_request(request)
      |> Game.update_response({:ok, :islands_set})
      |> Game.notify_player(opponent_id)
      |> GameServer.save()
      |> ReplyTuple.new(player_id)
    else
      :error ->
        ReplyTuple.new(action, game, request, player_id)

      false ->
        ReplyTuple.new(:not_all_islands_positioned, game, request, player_id)
    end
  end
end
