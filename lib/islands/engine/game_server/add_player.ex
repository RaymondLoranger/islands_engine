defmodule Islands.Engine.GameServer.AddPlayer do
  alias Islands.Engine.GameServer.ReplyTuple
  alias Islands.Engine.GameServer
  alias Islands.{Game, Request, State}

  @spec handle_call(Request.t(), GenServer.from(), Game.t()) :: ReplyTuple.t()
  def handle_call(
        {action = :add_player, name, gender, pid} = request,
        _from,
        game
      ) do
    with {:ok, state} <- State.check(game.state, action),
         false <- name == game.player1.name do
      game
      |> Game.update_player(:player2, name, gender, pid)
      |> Game.update_state(state)
      |> Game.update_request(request)
      |> Game.update_response({:ok, :player2_added})
      |> Game.notify_player(:player1)
      |> GameServer.save()
      |> ReplyTuple.new(:player2)
    else
      :error -> ReplyTuple.new(action, game, request, :player2)
      true -> ReplyTuple.new(:duplicate_player_name, game, request, :player2)
    end
  end
end
