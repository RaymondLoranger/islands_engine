defmodule Islands.Engine.Server.Error do
  alias Islands.Engine.Server
  alias Islands.{Game, PlayerID, Request}

  @player_turns [:player1_turn, :player2_turn]
  @position_actions [:position_island, :position_all_islands]

  @spec reply(atom, Game.t(), Request.t(), PlayerID.t()) :: Server.reply()
  def reply(:add_player = _action, game, request, player_id) do
    reason =
      case game.state.game_state do
        :initialized -> :unexpected
        :players_set -> :player2_already_added
        game_state when game_state in @player_turns -> :player2_already_added
        :game_over -> :game_over
      end

    reply(reason, game, request, player_id)
  end

  def reply(action, game, request, player_id)
      when action in @position_actions do
    reason =
      case game.state.game_state do
        :initialized -> :player2_not_added
        :players_set -> :islands_already_set
        game_state when game_state in @player_turns -> :islands_already_set
        :game_over -> :game_over
      end

    reply(reason, game, request, player_id)
  end

  def reply(:set_islands = _action, game, request, player_id) do
    reason =
      case game.state.game_state do
        :initialized -> :player2_not_added
        :players_set -> :unexpected
        game_state when game_state in @player_turns -> :both_players_islands_set
        :game_over -> :game_over
      end

    reply(reason, game, request, player_id)
  end

  def reply(:guess_coord = _action, game, request, player_id) do
    reason =
      case game.state.game_state do
        :initialized -> :player2_not_added
        :players_set -> :not_both_players_islands_set
        game_state when game_state in @player_turns -> :not_player_turn
        :game_over -> :game_over
      end

    reply(reason, game, request, player_id)
  end

  def reply(:stop = _action, game, request, player_id) do
    reason =
      case game.state.game_state do
        :initialized -> :player2_not_added
        :players_set -> :not_both_players_islands_set
        game_state when game_state in @player_turns -> :not_player_turn
        :game_over -> :game_over
      end

    reply(reason, game, request, player_id)
  end

  def reply(reason, game, request, player_id) do
    game
    |> Game.update_request(request)
    |> Game.update_response({:error, reason})
    |> Server.save()
    |> Server.reply(player_id)
  end
end
