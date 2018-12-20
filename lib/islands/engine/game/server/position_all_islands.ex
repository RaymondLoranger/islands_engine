defmodule Islands.Engine.Game.Server.PositionAllIslands do
  alias Islands.Engine.Board.Server, as: BoardServer
  alias Islands.Engine.Game.Server.Error
  alias Islands.Engine.Game.{Server, State}
  alias Islands.Engine.{Board, Game}

  @spec handle_call(Server.request(), Server.from(), Game.t()) :: Server.reply()
  def handle_call(
        {:position_all_islands = action, player_id} = request,
        _from,
        game
      ) do
    with {:ok, state} <- State.check(game.state, {action, player_id}),
         %Board{} = board <- BoardServer.restore_board() do
      game
      |> Game.update_board(player_id, board)
      |> Game.update_state(state)
      |> Game.update_request(request)
      |> Game.update_response({:ok, :all_islands_positioned})
      |> Server.save()
      |> Server.reply(player_id)
    else
      :error ->
        Error.reply(game, request, :islands_already_set, player_id)

      {:error, reason} when is_atom(reason) ->
        Error.reply(game, request, reason, player_id)

      non_matched_value ->
        :ok = Error.log(:handle_call, {non_matched_value, request, game})
        Error.reply(game, request, :unknown, player_id)
    end
  end
end
