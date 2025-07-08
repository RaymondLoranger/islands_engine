defmodule Islands.Engine.GameServer.ReplyTuple do
  alias Islands.Engine.GameServer
  alias Islands.{Game, PlayerID, Request, Tally}

  @player_turns [:player1_turn, :player2_turn]
  @position_actions [:position_island, :position_all_islands]
  @timeout :timer.minutes(30)

  @typedoc "Action like :add_player or reason like :duplicate_player_name"
  @type action_or_reason :: atom
  @type t :: {:reply, Tally.t(), Game.t(), timeout}

  @spec new(Game.t(), PlayerID.t()) :: t
  def new(game, player_id),
    do: {:reply, Tally.new(game, player_id), game, @timeout}

  @spec new(action_or_reason, Game.t(), Request.t(), PlayerID.t()) :: t
  def new(_action = :add_player, game, request, player_id) do
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

  def new(_action = :set_islands, game, request, player_id) do
    reason =
      case game.state.game_state do
        :initialized -> :player2_not_added
        :players_set -> :unexpected
        game_state when game_state in @player_turns -> :both_players_islands_set
        :game_over -> :game_over
      end

    new(reason, game, request, player_id)
  end

  def new(_action = :guess_coord, game, request, player_id) do
    reason =
      case game.state.game_state do
        :initialized -> :player2_not_added
        :players_set -> :not_both_players_islands_set
        game_state when game_state in @player_turns -> :not_player_turn
        :game_over -> :game_over
      end

    new(reason, game, request, player_id)
  end

  def new(_action = :stop, game, request, player_id) do
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
