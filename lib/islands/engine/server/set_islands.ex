defmodule Islands.Engine.Server.SetIslands do
  @moduledoc false

  alias Islands.Engine.Server.Error
  alias Islands.Engine.{Board, Game, Server, State, Tally}

  @typep from :: GenServer.from()

  @spec handle_call(term, from, Game.t()) :: {:reply, Tally.t(), Game.t()}
  def handle_call({:set_islands = action, player_id} = request, _from, game) do
    with {:ok, state} <- State.check(game.state, {action, player_id}),
         %Board{} = board <- Game.player_board(game, player_id),
         true <- Board.all_islands_positioned?(board) do
      opponent_id = Game.opponent(player_id)

      game
      |> Game.update_state(state)
      |> Game.update_request(request)
      |> Game.update_response({:ok, :islands_set})
      |> Game.notify_player(opponent_id)
      |> Server.save()
      |> Server.reply(player_id)
    else
      :error ->
        game
        |> Game.update_request(request)
        |> Game.update_response({:error, :both_players_islands_set})
        |> Server.save()
        |> Server.reply(player_id)

      false ->
        game
        |> Game.update_request(request)
        |> Game.update_response({:error, :not_all_islands_positioned})
        |> Server.save()
        |> Server.reply(player_id)

      non_matched_value ->
        Error.log(non_matched_value, request)

        game
        |> Game.update_request(request)
        |> Game.update_response({:error, :unknown})
        |> Server.save()
        |> Server.reply(player_id)
    end
  end
end
