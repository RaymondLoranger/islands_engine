defmodule Islands.Engine.Server.PositionIsland do
  alias Islands.Engine.Server.{Error, Log}
  alias Islands.Engine.Server
  alias Islands.Board.Cache
  alias Islands.{Board, Coord, Game, Island, Request, State}

  @spec handle_call(Request.t(), Server.from(), Game.t()) :: Server.reply()
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
      response =
        {:ok,
         if Board.all_islands_positioned?(board) do
           Cache.persist_board(board)
           :all_islands_positioned
         else
           :island_positioned
         end}

      game
      |> Game.update_board(player_id, board)
      |> Game.update_state(state)
      |> Game.update_request(request)
      |> Game.update_response(response)
      |> Server.save()
      |> Server.reply(player_id)
    else
      :error ->
        Error.reply(action, game, request, player_id)

      {:error, reason} when is_atom(reason) ->
        Error.reply(reason, game, request, player_id)

      non_matched_value ->
        :ok = Log.error(:handle_call, {non_matched_value, request, game})
        Error.reply(:unknown, game, request, player_id)
    end
  end
end
