defmodule Islands.Engine.Server.PositionAllIslands do
  @moduledoc false

  alias Islands.Engine.Board.Set
  alias Islands.Engine.Server.Error
  alias Islands.Engine.{Board, Game, Server, State, Tally}

  @typep from :: GenServer.from()

  @spec handle_call(term, from, Game.t()) :: {:reply, Tally.t(), Game.t()}
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
        Error.log(non_matched_value, request)

        game
        |> Game.update_request(request)
        |> Game.update_response({:error, :unknown})
        |> Server.save()
        |> Server.reply(player_id)
    end
  end
end
