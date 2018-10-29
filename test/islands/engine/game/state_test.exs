defmodule Islands.Engine.Game.StateTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Islands.Engine.Game.State

  doctest State

  setup_all do
    initialized = State.new()
    {:ok, players_set} = State.check(initialized, :add_player)
    {:ok, player1_set} = State.check(players_set, {:set_islands, :player1})
    {:ok, player1_turn} = State.check(player1_set, {:set_islands, :player2})

    states = %{
      initialized: initialized,
      players_set: players_set,
      player1_set: player1_set,
      player1_turn: player1_turn
    }

    {:ok, states: states}
  end

  describe "State.new/0" do
    test "initialized state" do
      assert State.new() ==
               %State{
                 game_state: :initialized,
                 player1_state: :islands_not_set,
                 player2_state: :islands_not_set
               }
    end
  end

  describe "State.check/2" do
    test "add player", %{states: states} do
      {:ok, state} = State.check(states.initialized, :add_player)
      assert state.game_state == :players_set
    end

    test "bad request", %{states: states} do
      assert State.check(states.initialized, :bad_request) == :error
    end

    test "position island", %{states: states} do
      state = states.players_set
      {:ok, state} = State.check(state, {:position_island, :player1})
      {:ok, ^state} = State.check(state, {:position_island, :player1})
      {:ok, ^state} = State.check(state, {:position_island, :player2})
      {:ok, ^state} = State.check(state, {:position_island, :player2})
      assert state.game_state == :players_set
      assert state.player1_state == :islands_not_set
      assert state.player2_state == :islands_not_set
    end

    test "set islands", %{states: states} do
      state = states.players_set
      {:ok, state} = State.check(state, {:set_islands, :player1})
      :error = State.check(state, {:position_island, :player1})
      {:ok, ^state} = State.check(state, {:set_islands, :player1})
      {:ok, state} = State.check(state, {:set_islands, :player2})
      :error = State.check(state, :add_player)
      :error = State.check(state, {:set_islands, :player1})
      :error = State.check(state, {:set_islands, :player2})
      :error = State.check(state, {:position_island, :player1})
      :error = State.check(state, {:position_island, :player2})
      assert state.game_state == :player1_turn
      assert state.player1_state == :islands_set
      assert state.player2_state == :islands_set
    end

    test "guess coord", %{states: states} do
      state = states.player1_turn
      :error = State.check(state, {:guess_coord, :player2})
      {:ok, state} = State.check(state, {:guess_coord, :player1})
      assert state.game_state == :player2_turn
      {:ok, state} = State.check(state, {:guess_coord, :player2})
      assert state.game_state == :player1_turn
    end

    test "no win", %{states: states} do
      state = states.player1_turn
      {:ok, ^state} = State.check(state, {:win_check, :no_win})
      assert state.game_state == :player1_turn
    end

    test "win", %{states: states} do
      state = states.player1_turn
      {:ok, state} = State.check(state, {:win_check, :win})
      assert state.game_state == :game_over
    end

    test "stop", %{states: states} do
      state = states.player1_turn
      {:ok, state} = State.check(state, :stop)
      assert state.game_state == :game_over
    end
  end
end
