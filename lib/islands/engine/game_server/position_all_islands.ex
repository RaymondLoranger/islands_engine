defmodule Islands.Engine.GameServer.PositionAllIslands do
  alias Islands.Engine.GameServer.ReplyTuple
  alias Islands.Engine.GameServer
  alias Islands.Board.Cache
  alias Islands.{Board, Game, Request, State}

  @spec handle_call(Request.t(), GenServer.from(), Game.t()) :: ReplyTuple.t()
  def handle_call(
        {action = :position_all_islands, player_id} = request,
        _from,
        game
      ) do
    with {:ok, state} <- State.check(game.state, {action, player_id}),
         %Board{} = board <- Cache.get_board() do
      game
      |> Game.update_board(player_id, board)
      |> Game.update_state(state)
      |> Game.update_request(request)
      |> Game.update_response({:ok, :all_islands_positioned})
      |> GameServer.save()
      |> ReplyTuple.new(player_id)
    else
      :error -> ReplyTuple.new(action, game, request, player_id)
    end
  end
end
