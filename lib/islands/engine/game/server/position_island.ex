defmodule Islands.Engine.Game.Server.PositionIsland do
  alias Islands.Engine.Game.Server.Error
  alias Islands.Engine.Game.{Server, State}
  alias Islands.Engine.{Game, Log}
  alias Islands.Board.Cache
  alias Islands.{Board, Coord, Island}

  @spec handle_call(Server.request(), Server.from(), Game.t()) :: Server.reply()
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
        Error.reply(game, request, :islands_already_set, player_id)

      {:error, reason} when is_atom(reason) ->
        Error.reply(game, request, reason, player_id)

      non_matched_value ->
        :ok = Log.error(:handle_call, {non_matched_value, request, game})
        Error.reply(game, request, :unknown, player_id)
    end
  end
end
