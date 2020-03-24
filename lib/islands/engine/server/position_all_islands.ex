defmodule Islands.Engine.Server.PositionAllIslands do
  alias Islands.Engine.Server.{Error, Log}
  alias Islands.Engine.Server
  alias Islands.Board.Cache
  alias Islands.{Board, Game, Request, State}

  @spec handle_call(Request.t(), Server.from(), Game.t()) :: Server.reply()
  def handle_call(
        {:position_all_islands = action, player_id} = request,
        _from,
        game
      ) do
    with {:ok, state} <- State.check(game.state, {action, player_id}),
         %Board{} = board <- Cache.get_board() do
      game
      |> Game.update_board(player_id, board)
      |> Game.update_state(state)
      |> Game.update_request(request)
      |> Game.update_response({:ok, :all_islands_positioned})
      |> Server.save()
      |> Server.reply(player_id)
    else
      :error ->
        Error.reply(:islands_already_set, game, request, player_id)

      {:error, reason} when is_atom(reason) ->
        Error.reply(reason, game, request, player_id)

      non_matched_value ->
        :ok = Log.error(:handle_call, {non_matched_value, request, game})
        Error.reply(:unknown, game, request, player_id)
    end
  end
end
