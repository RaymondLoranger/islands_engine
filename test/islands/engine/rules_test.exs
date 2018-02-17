defmodule Islands.Engine.RulesTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Islands.Engine.Rules

  doctest Rules

  setup_all do
    initialized = Rules.new()
    {:ok, players_set} = Rules.check(initialized, :add_player)
    {:ok, player1_set} = Rules.check(players_set, {:set_islands, :player1})
    {:ok, player1_turn} = Rules.check(player1_set, {:set_islands, :player2})

    stages = %{
      initialized: initialized,
      players_set: players_set,
      player1_set: player1_set,
      player1_turn: player1_turn
    }

    {:ok, stages: stages}
  end

  describe "Rules.new/0" do
    test "initialized rules" do
      assert %Rules{state: :initialized} = Rules.new()
    end
  end

  describe "Rules.check/2" do
    test "add player", %{stages: stages} do
      {:ok, rules} = Rules.check(stages.initialized, :add_player)
      assert rules.state == :players_set
    end

    test "wrong action", %{stages: stages} do
      assert :error = Rules.check(stages.initialized, :wrong_action)
    end

    test "position islands", %{stages: stages} do
      rules = stages.players_set
      {:ok, rules} = Rules.check(rules, {:position_islands, :player1})
      {:ok, ^rules} = Rules.check(rules, {:position_islands, :player1})
      {:ok, ^rules} = Rules.check(rules, {:position_islands, :player2})
      {:ok, ^rules} = Rules.check(rules, {:position_islands, :player2})
      assert rules.state == :players_set
    end

    test "set islands", %{stages: stages} do
      rules = stages.players_set
      {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
      :error = Rules.check(rules, {:position_islands, :player1})
      {:ok, ^rules} = Rules.check(rules, {:set_islands, :player1})
      {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
      :error = Rules.check(rules, :add_player)
      :error = Rules.check(rules, {:set_islands, :player1})
      :error = Rules.check(rules, {:set_islands, :player2})
      :error = Rules.check(rules, {:position_islands, :player1})
      :error = Rules.check(rules, {:position_islands, :player2})
      assert rules.state == :player1_turn
    end

    test "guess coordinate", %{stages: stages} do
      rules = stages.player1_turn
      :error = Rules.check(rules, {:guess_coordinate, :player2})
      {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})
      assert rules.state == :player2_turn
      {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player2})
      assert rules.state == :player1_turn
    end

    test "no win", %{stages: stages} do
      rules = stages.player1_turn
      {:ok, rules} = Rules.check(rules, {:win_check, :no_win})
      assert rules.state == :player1_turn
    end

    test "win", %{stages: stages} do
      rules = stages.player1_turn
      {:ok, rules} = Rules.check(rules, {:win_check, :win})
      assert rules.state == :game_over
    end
  end
end
