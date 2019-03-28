defmodule Islands.Engine.Game.Tally do
  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.Game.{Server, State}
  alias Islands.Engine.Game
  alias Islands.{Board, Guesses, Island}

  @enforce_keys [
    :game_state,
    :player1_state,
    :player2_state,
    :request,
    :response,
    :board,
    :guesses,
    :board_forested_types,
    :guesses_forested_types
  ]
  defstruct [
    :game_state,
    :player1_state,
    :player2_state,
    :request,
    :response,
    :board,
    :guesses,
    :board_forested_types,
    :guesses_forested_types
  ]

  @type t :: %Tally{
          game_state: State.game_state(),
          player1_state: State.player_state(),
          player2_state: State.player_state(),
          request: Server.request(),
          response: Server.response(),
          board: Board.t(),
          guesses: Guesses.t(),
          board_forested_types: [Island.type()],
          guesses_forested_types: [Island.type()]
        }

  @player_ids Application.get_env(@app, :player_ids)

  @dialyzer {:nowarn_function, new: 2}
  @spec new(Game.t(), Game.player_id()) :: t | {:error, atom}
  def new(%Game{} = game, player_id) when player_id in @player_ids do
    player = game[player_id]
    opponent = game[Game.opponent(player_id)]

    %Tally{
      game_state: game.state.game_state,
      player1_state: game.state.player1_state,
      player2_state: game.state.player2_state,
      request: game.request,
      response: game.response,
      board: player.board,
      guesses: player.guesses,
      board_forested_types: Board.forested_types(player.board),
      guesses_forested_types: Board.forested_types(opponent.board)
    }
  end

  def new(_game, _player_id), do: {:error, :invalid_tally_args}
end
