defmodule Islands.Engine.Game.Tally do
  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.Game.{Server, State}
  alias Islands.Engine.Game
  alias Islands.{Board, Guesses}

  @enforce_keys [
    :game_state,
    :player1_state,
    :player2_state,
    :request,
    :response,
    :board,
    :guesses
  ]
  defstruct [
    :game_state,
    :player1_state,
    :player2_state,
    :request,
    :response,
    :board,
    :guesses
  ]

  @type t :: %Tally{
          game_state: State.game_state(),
          player1_state: State.player_state(),
          player2_state: State.player_state(),
          request: Server.request(),
          response: Server.response(),
          board: Board.t(),
          guesses: Guesses.t()
        }

  @player_ids Application.get_env(@app, :player_ids)

  @spec new(Game.t(), Game.player_id()) :: t | {:error, atom}
  def new(%Game{} = game, player_id) when player_id in @player_ids do
    %Tally{
      game_state: game.state.game_state,
      player1_state: game.state.player1_state,
      player2_state: game.state.player2_state,
      request: game.request,
      response: game.response,
      board: game[player_id].board,
      guesses: game[player_id].guesses
    }
  end

  def new(_game, _player_id), do: {:error, :invalid_tally_args}
end
