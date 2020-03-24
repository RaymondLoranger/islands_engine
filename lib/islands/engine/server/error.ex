defmodule Islands.Engine.Server.Error do
  alias Islands.Engine.Server
  alias Islands.{Game, PlayerID, Request}

  @spec reply(Game.t(), Request.t(), atom, PlayerID.t()) :: Server.reply()
  def reply(game, request, :set_islands, player_id) do
    case game.state.game_state do
      :initialized ->
        reply(game, request, :player2_not_added, player_id)

      state when state in [:player1_turn, :player2_turn] ->
        reply(game, request, :both_players_islands_set, player_id)

      :game_over ->
        reply(game, request, :game_over, player_id)
    end
  end

  def reply(game, request, :stop, player_id) do
    case game.state.game_state do
      :initialized ->
        reply(game, request, :player2_not_added, player_id)

      :players_set ->
        reply(game, request, :not_both_players_islands_set, player_id)

      :game_over ->
        reply(game, request, :game_over, player_id)
    end
  end

  def reply(game, request, :guess_coord, player_id) do
    case game.state.game_state do
      state when state in [:initialized, :players_set] ->
        reply(game, request, :not_both_players_islands_set, player_id)

      state when state in [:player1_turn, :player2_turn] ->
        reply(game, request, :not_player_turn, player_id)

      :game_over ->
        reply(game, request, :game_over, player_id)
    end
  end

  def reply(game, request, reason, player_id) do
    game
    |> Game.update_request(request)
    |> Game.update_response({:error, reason})
    |> Server.save()
    |> Server.reply(player_id)
  end
end
