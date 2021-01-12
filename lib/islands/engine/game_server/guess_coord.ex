defmodule Islands.Engine.GameServer.GuessCoord do
  alias Islands.Engine.GameServer.ReplyTuple
  alias Islands.Engine.GameServer
  alias Islands.{Board, Coord, Game, Request, State}

  @spec handle_call(Request.t(), GenServer.from(), Game.t()) :: ReplyTuple.t()
  def handle_call(
        {:guess_coord = action, player_id, row, col} = request,
        _from,
        game
      ) do
    with {:ok, state} <- State.check(game.state, {action, player_id}),
         {:ok, guess} <- Coord.new(row, col),
         opponent_id = Game.opponent_id(player_id),
         %Board{} = opponent_board <- Game.player_board(game, opponent_id),
         {hit_or_miss, forested_island_type, win_status, opponent_board} <-
           Board.guess(opponent_board, guess),
         {:ok, state} <- State.check(state, {:win_check, win_status}) do
      game
      |> Game.update_board(opponent_id, opponent_board)
      |> Game.update_guesses(player_id, hit_or_miss, guess)
      |> Game.update_state(state)
      |> Game.update_request(request)
      |> Game.update_response({hit_or_miss, forested_island_type, win_status})
      |> Game.notify_player(opponent_id)
      |> GameServer.save()
      |> ReplyTuple.new(player_id)
    else
      :error ->
        ReplyTuple.new(action, game, request, player_id)

      {:error, reason} when is_atom(reason) ->
        ReplyTuple.new(reason, game, request, player_id)
    end
  end
end
