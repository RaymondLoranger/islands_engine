defmodule Islands.Engine.Server.PositionAllIslands do
  @moduledoc false

  alias Islands.Engine.Board.Set
  alias Islands.Engine.Server.Error
  alias Islands.Engine.{Board, Game, Server, State}

  @spec handle_call(Server.request(), Server.from(), Game.t()) :: Server.reply()
  def handle_call(
        {:position_all_islands = action, player_id} = request,
        _from,
        game
      ) do
    with {:ok, state} <- State.check(game.state, {action, player_id}),
         %Board{} = board <- Set.restore_board() do
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
        Error.log(:handle_call, non_matched_value, request)
        Error.reply(game, request, :unknown, player_id)
    end
  end
end
