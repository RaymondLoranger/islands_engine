# State machine...
defmodule Islands.Engine.State do
  @moduledoc false

  @behaviour Access

  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.Game

  defstruct game: :initialized,
            player1: :islands_not_set,
            player2: :islands_not_set

  @type game_state ::
          :initialized
          | :players_set
          | :player1_turn
          | :player2_turn
          | :game_over
  @type player_state :: :islands_not_set | :islands_set
  @type t :: %State{
          game: game_state,
          player1: player_state,
          player2: player_state
        }

  @typep request ::
           :add_player
           | {:position_island, Game.player_id()}
           | {:position_all_islands, Game.player_id()}
           | {:set_islands, Game.player_id()}
           | {:guess_coord, Game.player_id()}
           | {:win_check, win_status}
           | :stop
  @typep win_status :: :no_win | :win

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
  def check(%State{game: :initialized} = state, :add_player) do
    {:ok, put_in(state.game, :players_set)}
  end

  def check(%State{game: :players_set} = state, {action, player_id})
      when action in @position_actions and player_id in @player_ids do
    case state[player_id] do
      :islands_set -> :error
      :islands_not_set -> {:ok, state}
    end
  end

  def check(%State{game: :players_set} = state, {:set_islands, player_id})
      when player_id in @player_ids do
    state = put_in(state[player_id], :islands_set)

    if both_players_islands_set?(state),
      do: {:ok, put_in(state.game, :player1_turn)},
      else: {:ok, state}
  end

  def check(%State{game: :player1_turn} = state, {:guess_coord, :player1}) do
    {:ok, put_in(state.game, :player2_turn)}
  end

  def check(%State{game: :player2_turn} = state, {:guess_coord, :player2}) do
    {:ok, put_in(state.game, :player1_turn)}
  end

  def check(%State{game: player_turn} = state, {:win_check, :no_win})
      when player_turn in @player_turns do
    {:ok, state}
  end

  def check(%State{game: player_turn} = state, {:win_check, :win})
      when player_turn in @player_turns do
    {:ok, put_in(state.game, :game_over)}
  end

  def check(%State{game: player_turn} = state, :stop)
      when player_turn in @player_turns do
    {:ok, put_in(state.game, :game_over)}
  end

  def check(_state, _request), do: :error

  ## Private functions

  @spec both_players_islands_set?(t) :: boolean
  defp both_players_islands_set?(state) do
    state.player1 == :islands_set and state.player2 == :islands_set
  end
end
