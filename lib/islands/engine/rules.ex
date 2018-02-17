defmodule Islands.Engine.Rules do
  # @moduledoc """
  # Rules module...
  # """
  @moduledoc false

  alias __MODULE__

  defstruct state: :initialized,
            player1: :islands_not_set,
            player2: :islands_not_set

  @type action ::
          :add_player
          | {:position_islands, player_id}
          | {:set_islands, player_id}
          | {:guess_coordinate, player_id}
          | {:win_check, maybe_win}
  @type maybe_win :: :no_win | :win
  @type player_id :: :player1 | :player2
  @type player_state :: :islands_not_set | :islands_set
  @type state ::
          :initialized
          | :players_set
          | :player1_turn
          | :player2_turn
          | :game_over
  @type t :: %Rules{state: state, player1: player_state, player2: player_state}

  @spec new() :: t
  def new(), do: %Rules{}

  @spec check(t, action) :: t | :error
  def check(%Rules{state: :initialized} = rules, :add_player) do
    {:ok, %Rules{rules | state: :players_set}}
  end

  def check(%Rules{state: :players_set} = rules, {:position_islands, player_id})
      when player_id in [:player1, :player2] do
    case Map.fetch!(rules, player_id) do
      :islands_set -> :error
      :islands_not_set -> {:ok, rules}
    end
  end

  def check(%Rules{state: :players_set} = rules, {:set_islands, player_id})
      when player_id in [:player1, :player2] do
    rules = Map.put(rules, player_id, :islands_set)

    if both_players_islands_set?(rules),
      do: {:ok, %Rules{rules | state: :player1_turn}},
      else: {:ok, rules}
  end

  def check(
        %Rules{state: :player1_turn} = rules,
        {:guess_coordinate, :player1}
      ),
      do: {:ok, %Rules{rules | state: :player2_turn}}

  def check(
        %Rules{state: :player2_turn} = rules,
        {:guess_coordinate, :player2}
      ) do
    {:ok, %Rules{rules | state: :player1_turn}}
  end

  def check(%Rules{state: player_turn} = rules, {:win_check, :no_win})
      when player_turn in [:player1_turn, :player2_turn] do
    {:ok, rules}
  end

  def check(%Rules{state: player_turn} = rules, {:win_check, :win})
      when player_turn in [:player1_turn, :player2_turn] do
    {:ok, %Rules{rules | state: :game_over}}
  end

  def check(_state, _action), do: :error

  ## Private functions

  @spec both_players_islands_set?(t) :: boolean
  defp both_players_islands_set?(rules) do
    rules.player1 == :islands_set and rules.player2 == :islands_set
  end
end
