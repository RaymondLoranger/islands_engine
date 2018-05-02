defmodule Islands.Engine.Tally do
  @moduledoc false

  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.Tally.Score
  alias Islands.Engine.{Game, Grid, Server, State}

  @enforce_keys [
    :game_state,
    :player1_state,
    :player2_state,
    :request,
    :response,
    :board,
    :guesses,
    :board_score,
    :guesses_score
  ]
  defstruct [
    :game_state,
    :player1_state,
    :player2_state,
    :request,
    :response,
    :board,
    :guesses,
    :board_score,
    :guesses_score
  ]

  @type t :: %Tally{
          game_state: State.game_state(),
          player1_state: State.player_state(),
          player2_state: State.player_state(),
          request: Server.request(),
          response: Server.response(),
          board: Grid.t(),
          guesses: Grid.t(),
          board_score: {atom, non_neg_integer, non_neg_integer},
          guesses_score: {atom, non_neg_integer, non_neg_integer}
        }

  @player_ids Application.get_env(@app, :player_ids)

  @spec new(Game.t(), Game.player_id()) :: t
  def new(%Game{} = game, player_id) when player_id in @player_ids do
    %Tally{
      game_state: game.state.game,
      player1_state: game.state.player1,
      player2_state: game.state.player2,
      request: game.request,
      response: game.response,
      board: game[player_id].board |> Grid.new(),
      guesses: game[player_id].guesses |> Grid.new(),
      board_score: game[player_id].board |> Score.for(),
      guesses_score: game[player_id].guesses |> Score.for()
    }
  end

  def new(_game, _player_id), do: {:error, :invalid_tally_args}
end
