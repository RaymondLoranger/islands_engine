defmodule Islands.Engine.Server.AddPlayer do
  @moduledoc false

  alias Islands.Engine.{Game, Server, State, Tally}

  @typep from :: GenServer.from()

  @spec handle_call(term, from, Game.t()) :: {:reply, Tally.t(), Game.t()}
  def handle_call({:add_player = action, name, pid} = request, _from, game) do
    with {:ok, state} <- State.check(game.state, action) do
      game
      |> Game.update_player2_name(name)
      |> Game.update_player_pid(:player2, pid)
      |> Game.update_state(state)
      |> Game.update_request(request)
      |> Game.update_response({:ok, :player2_added})
      |> Game.notify_player(:player1)
      |> Server.save()
      |> Server.reply(:player2)
    else
      :error ->
        game
        |> Game.update_request(request)
        |> Game.update_response({:error, :player2_already_added})
        |> Server.save()
        |> Server.reply(:player2)
    end
  end
end
