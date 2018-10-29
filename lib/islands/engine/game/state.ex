defmodule Islands.Engine.Game.State do
  # State machine...
  @moduledoc false

  @behaviour Access

  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.Game

  defstruct game_state: :initialized,
            player1_state: :islands_not_set,
            player2_state: :islands_not_set

  @type game_state ::
          :initialized
          | :players_set
          | :player1_turn
          | :player2_turn
          | :game_over
  @type player_state :: :islands_not_set | :islands_set
  @type t :: %State{
          game_state: game_state,
          player1_state: player_state,
          player2_state: player_state
        }

  @typep request ::
           :add_player
           | {:position_island, Game.player_id()}
           | {:position_all_islands, Game.player_id()}
           | {:set_islands, Game.player_id()}
           | {:guess_coord, Game.player_id()}
           | {:win_check, :no_win | :win}
           | :stop

  @player_ids Application.get_env(@app, :player_ids)
  @player_turns [:player1_turn, :player2_turn]
  @position_actions [:position_island, :position_all_islands]

  # Access behaviour
  defdelegate fetch(state, key), to: Map
  defdelegate get(state, key, default), to: Map
  defdelegate get_and_update(state, key, fun), to: Map
  defdelegate pop(state, key), to: Map

  @spec new() :: t
  def new(), do: %State{}

  @spec check(t, request) :: {:ok, t} | :error
  def check(%State{game_state: :initialized} = state, :add_player),
    do: {:ok, put_in(state.game_state, :players_set)}

  def check(%State{game_state: :players_set} = state, {action, player_id})
      when action in @position_actions and player_id in @player_ids do
    case state[state_key(player_id)] do
      :islands_not_set -> {:ok, state}
      :islands_set -> :error
    end
  end

  def check(%State{game_state: :players_set} = state, {:set_islands, player_id})
      when player_id in @player_ids do
    state = put_in(state[state_key(player_id)], :islands_set)

    if both_players_islands_set?(state),
      do: {:ok, put_in(state.game_state, :player1_turn)},
      else: {:ok, state}
  end

  def check(
        %State{game_state: :player1_turn} = state,
        {:guess_coord, :player1}
      ),
      do: {:ok, put_in(state.game_state, :player2_turn)}

  def check(
        %State{game_state: :player2_turn} = state,
        {:guess_coord, :player2}
      ),
      do: {:ok, put_in(state.game_state, :player1_turn)}

  def check(%State{game_state: player_turn} = state, {:win_check, :no_win})
      when player_turn in @player_turns,
      do: {:ok, state}

  def check(%State{game_state: player_turn} = state, {:win_check, :win})
      when player_turn in @player_turns,
      do: {:ok, put_in(state.game_state, :game_over)}

  def check(%State{game_state: player_turn} = state, :stop)
      when player_turn in @player_turns,
      do: {:ok, put_in(state.game_state, :game_over)}

  def check(_state, _request), do: :error

  ## Private functions

  @spec both_players_islands_set?(t) :: boolean
  defp both_players_islands_set?(state) do
    state.player1_state == :islands_set and state.player2_state == :islands_set
  end

  @spec state_key(Game.player_id()) :: atom
  defp state_key(player_id), do: :"#{player_id}_state"
end
