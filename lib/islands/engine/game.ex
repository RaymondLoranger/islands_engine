defmodule Islands.Engine.Game do
  # @moduledoc """
  # Implements an Islands game.
  # """
  @moduledoc false

  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.{Board, Guesses, Rules}

  @enforce_keys [:player1, :player2]
  defstruct player1: %{},
            player2: %{},
            rules: Rules.new()

  @type player :: map
  @type t :: %Game{player1: player, player2: player, rules: Rules.t()}
  @type tally :: map

  @players Application.get_env(@app, :players)

  # @doc """
  # Returns a new Islands game.

  # ## Examples

  #     iex> alias Hangman.Engine.Game
  #     iex> Game.new_game("Mr. Smith").game_state
  #     :initializing
  # """
  # @spec new_game(String.t(), String.t()) :: t
  def new_game(name) when is_binary(name) do
    %Game{
      player1: %{name: name, board: Board.new(), guesses: Guesses.new()},
      player2: %{name: nil, board: Board.new(), guesses: Guesses.new()}
    }
  end

  def update_board(game, player_id, board) do
    # Map.update!(game, player_id, fn player -> %{player | board: board} end)
    # update_in(state, [player_id, board], &(board || &1))
    update_in(game[player_id].board, fn _ -> board end)
  end

  def update_guesses(game, player_id, hit_or_miss, coord) do
    # update_in(game[player_id].guesses, fn guesses ->
    #   Guesses.add(guesses, hit_or_miss, coord)
    # end)
    update_in(game[player_id].guesses, &Guesses.add(&1, hit_or_miss, coord))
  end

  def update_player2_name(%Game{} = game, name) when is_binary(name) do
    put_in(game.player2.name, name)
  end

  def tally(%Game{} = _game, player) when player in @players do
    nil
  end

  def player_board(state, player_id), do: get_in(state, [player_id, :board])

  def opponent(:player1), do: :player2
  def opponent(:player2), do: :player1

  def update_rules(game, rules), do: %Game{game | rules: rules}
end
