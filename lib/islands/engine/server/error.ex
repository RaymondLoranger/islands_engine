defmodule Islands.Engine.Server.Error do
  alias Islands.Engine.Server
  alias Islands.{Game, PlayerID, Request}

  @player_turns [:player1_turn, :player2_turn]
  @position_actions [:position_island, :position_all_islands]

  @spec reply(atom, Game.t(), Request.t(), PlayerID.t()) :: Server.reply()
  def reply(:set_islands, game, request, player_id) do
    case game.state.game_state do
      :initialized ->
        reply(:player2_not_added, game, request, player_id)

      state when state in @player_turns ->
        reply(:both_players_islands_set, game, request, player_id)

      :game_over ->
        reply(:game_over, game, request, player_id)
    end
  end

  def reply(:stop, game, request, player_id) do
    case game.state.game_state do
      :initialized ->
        reply(:player2_not_added, game, request, player_id)

      :players_set ->
        reply(:not_both_players_islands_set, game, request, player_id)

      :game_over ->
        reply(:game_over, game, request, player_id)
    end
  end

  def reply(:guess_coord, game, request, player_id) do
    case game.state.game_state do
      :initialized ->
        reply(:player2_not_added, game, request, player_id)

      :players_set ->
        reply(:not_both_players_islands_set, game, request, player_id)

      state when state in @player_turns ->
        reply(:not_player_turn, game, request, player_id)

      :game_over ->
        reply(:game_over, game, request, player_id)
    end
  end

  def reply(action, game, request, player_id)
      when action in @position_actions do
    case game.state.game_state do
      :players_set ->
        reply(:islands_already_set, game, request, player_id)

      state when state in @player_turns ->
        reply(:islands_already_set, game, request, player_id)

      :game_over ->
        reply(:game_over, game, request, player_id)
    end
  end

  def reply(reason, game, request, player_id) do
    game
    |> Game.update_request(request)
    |> Game.update_response({:error, reason})
    |> Server.save()
    |> Server.reply(player_id)
  end
end
