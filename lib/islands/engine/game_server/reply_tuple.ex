defmodule Islands.Engine.GameServer.ReplyTuple do
  alias Islands.Engine.GameServer
  alias Islands.{Game, PlayerID, Request, Tally}

  @player_turns [:player1_turn, :player2_turn]
  @position_actions [:position_island, :position_all_islands]

  @type t :: {:reply, Tally.t(), Game.t()}

  @spec new(Game.t(), PlayerID.t()) :: t
  def new(game, player_id), do: {:reply, Tally.new(game, player_id), game}

  @spec new(action_or_reason :: atom, Game.t(), Request.t(), PlayerID.t()) :: t
  def new(:add_player = _action, game, request, player_id) do
    reason =
      case game.state.game_state do
        :initialized -> :unexpected
        :players_set -> :player2_already_added
        game_state when game_state in @player_turns -> :player2_already_added
        :game_over -> :game_over
      end

    new(reason, game, request, player_id)
  end

  def new(action, game, request, player_id) when action in @position_actions do
    reason =
      case game.state.game_state do
        :initialized -> :player2_not_added
        :players_set -> :islands_already_set
        game_state when game_state in @player_turns -> :islands_already_set
        :game_over -> :game_over
      end

    new(reason, game, request, player_id)
  end

  def new(:set_islands = _action, game, request, player_id) do
    reason =
      case game.state.game_state do
        :initialized -> :player2_not_added
        :players_set -> :unexpected
        game_state when game_state in @player_turns -> :both_players_islands_set
        :game_over -> :game_over
      end

    new(reason, game, request, player_id)
  end

  def new(:guess_coord = _action, game, request, player_id) do
    reason =
      case game.state.game_state do
        :initialized -> :player2_not_added
        :players_set -> :not_both_players_islands_set
        game_state when game_state in @player_turns -> :not_player_turn
        :game_over -> :game_over
      end

    new(reason, game, request, player_id)
  end

  def new(:stop = _action, game, request, player_id) do
    reason =
      case game.state.game_state do
        :initialized -> :player2_not_added
        :players_set -> :not_both_players_islands_set
        game_state when game_state in @player_turns -> :not_player_turn
        :game_over -> :game_over
      end

    new(reason, game, request, player_id)
  end

  def new(reason, game, request, player_id) do
    game
    |> Game.update_request(request)
    |> Game.update_response({:error, reason})
    |> GameServer.save()
    |> new(player_id)
  end
end
