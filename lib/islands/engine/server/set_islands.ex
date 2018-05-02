defmodule Islands.Engine.Server.SetIslands do
  @moduledoc false

  alias Islands.Engine.Server.Error
  alias Islands.Engine.{Board, Game, Server, State}

  @spec handle_call(Server.request(), Server.from(), Game.t()) :: Server.reply()
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
        Error.reply(game, request, :both_players_islands_set, player_id)

      false ->
        Error.reply(game, request, :not_all_islands_positioned, player_id)

      non_matched_value ->
        Error.log(:handle_call, non_matched_value, request)
        Error.reply(game, request, :unknown, player_id)
    end
  end
end
