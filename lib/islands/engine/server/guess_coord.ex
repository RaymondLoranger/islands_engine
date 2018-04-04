defmodule Islands.Engine.Server.GuessCoord do
  @moduledoc false

  alias Islands.Engine.{Board, Coord, Game, Server, State, Tally}

  @typep from :: GenServer.from()

  @spec handle_call(term, from, Game.t()) :: {:reply, Tally.t(), Game.t()}
  def handle_call(
        {:guess_coord = action, player_id, row, col} = request,
        _from,
        game
      ) do
    with {:ok, state} <- State.check(game.state, {action, player_id}),
         {:ok, guess} <- Coord.new(row, col),
         opponent_id = Game.opponent(player_id),
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
        game
        |> Game.update_request(request)
        |> Game.update_response({:error, :islands_not_set})
        |> Server.save()
        |> Server.reply(player_id)

      {:error, reason} ->
        game
        |> Game.update_request(request)
        |> Game.update_response({:error, reason})
        |> Server.save()
        |> Server.reply(player_id)

      _other ->
        game
        |> Game.update_request(request)
        |> Game.update_response({:error, :unknown})
        |> Server.save()
        |> Server.reply(player_id)
    end
  end
end
