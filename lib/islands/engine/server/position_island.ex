defmodule Islands.Engine.Server.PositionIsland do
  @moduledoc false

  alias Islands.Engine.Server.Error
  alias Islands.Engine.{Board, Coord, Game, Island, Server, State, Tally}

  @typep from :: GenServer.from()

  @spec handle_call(term, from, Game.t()) :: {:reply, Tally.t(), Game.t()}
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
           GenServer.cast(self(), {:persist_board, board})
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
        game
        |> Game.update_request(request)
        |> Game.update_response({:error, :islands_already_set})
        |> Server.save()
        |> Server.reply(player_id)

      {:error, reason} when is_atom(reason) ->
        game
        |> Game.update_request(request)
        |> Game.update_response({:error, reason})
        |> Server.save()
        |> Server.reply(player_id)

      non_matched_value ->
        Error.log(:handle_call, non_matched_value, request)

        game
        |> Game.update_request(request)
        |> Game.update_response({:error, :unknown})
        |> Server.save()
        |> Server.reply(player_id)
    end
  end
end
