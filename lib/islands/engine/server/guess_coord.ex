defmodule Islands.Engine.Server.GuessCoord do
  alias Islands.Engine.Server.{Error, Log}
  alias Islands.Engine.Server
  alias Islands.{Board, Coord, Game, Request, State}

  @spec handle_call(Request.t(), Server.from(), Game.t()) :: Server.reply()
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
      |> Server.save()
      |> Server.reply(player_id)
    else
      :error ->
        Error.reply(game, request, :not_both_players_islands_set, player_id)

      {:error, reason} when is_atom(reason) ->
        Error.reply(game, request, reason, player_id)

      non_matched_value ->
        :ok = Log.error(:handle_call, {non_matched_value, request, game})
        Error.reply(game, request, :unknown, player_id)
    end
  end
end
