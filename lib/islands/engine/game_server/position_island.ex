defmodule Islands.Engine.GameServer.PositionIsland do
  alias Islands.Engine.GameServer.ReplyTuple
  alias Islands.Engine.GameServer
  alias Islands.{Board, Coord, Game, Island, Request, State}

  @spec handle_call(Request.t(), GenServer.from(), Game.t()) :: ReplyTuple.t()
  def handle_call(
        {:position_island = action, player_id, island_type, row, col} = request,
        _from,
        game
      ) do
    with {:ok, state} <- State.check(game.state, {action, player_id}),
         {:ok, origin} <- Coord.new(row, col),
         {:ok, island} <- Island.new(island_type, origin),
         %Board{} = board <- Game.player_board(game, player_id),
         %Board{} = board <- Board.position_island(board, island) do
      response = {:ok, Board.all_islands_positioned?(board) |> response()}

      game
      |> Game.update_board(player_id, board)
      |> Game.update_state(state)
      |> Game.update_request(request)
      |> Game.update_response(response)
      |> GameServer.save()
      |> ReplyTuple.new(player_id)
    else
      :error ->
        ReplyTuple.new(action, game, request, player_id)

      {:error, reason} when is_atom(reason) ->
        ReplyTuple.new(reason, game, request, player_id)
    end
  end

  ## Private functions

  defp response(_all_islands_positioned = true), do: :all_islands_positioned
  defp response(_not_all_islands_positioned), do: :island_positioned
end
