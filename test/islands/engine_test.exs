defmodule Islands.EngineTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Islands.Engine
  alias Islands.Engine.Tally

  doctest Engine

  describe "Engine.new_game/2" do
    test "starts a new game" do
      me = self()
      {:ok, game_id} = Engine.new_game("Meg", me)
      assert is_pid(game_id)
    end

    test "fails to start a game" do
      me = self()
      {:ok, game_id} = Engine.new_game("Mel", me)
      assert {:error, {:already_started, ^game_id}} = Engine.new_game("Mel", me)
    end
  end

  describe "Engine.end_game/1" do
    test "ends a game" do
      me = self()
      Engine.new_game("Ben", me)
      assert Engine.end_game("Ben") == :ok
    end
  end

  describe "Engine.stop_game/2" do
    test "fails to stop a game" do
      him = self()
      her = self()
      Engine.new_game("Tarzan", him)
      Engine.add_player("Tarzan", "Jane", her)
      Engine.position_all_islands("Tarzan", :player2)
      Engine.set_islands("Tarzan", :player2)

      assert %Tally{response: {:error, :not_both_players_islands_set}} =
               Engine.stop_game("Tarzan", :player2)
    end

    test "stops a game" do
      him = self()
      her = self()
      Engine.new_game("Sonny", him)
      Engine.add_player("Sonny", "Cher", her)
      Engine.position_all_islands("Sonny", :player2)
      Engine.set_islands("Sonny", :player2)
      Engine.position_all_islands("Sonny", :player1)
      Engine.set_islands("Sonny", :player1)

      assert %Tally{response: {:ok, :stopping}} =
               Engine.stop_game("Sonny", :player2)
    end
  end

  describe "Engine.add_player/3" do
    test "adds second player" do
      him = self()
      her = self()
      Engine.new_game("Romeo", him)

      assert %Tally{response: {:ok, :player2_added}} =
               Engine.add_player("Romeo", "Juliet", her)
    end

    test "fails to add second player" do
      him = self()
      her = self()
      Engine.new_game("Brad", him)
      Engine.add_player("Brad", "Angelina", her)

      assert %Tally{response: {:error, :player2_already_added}} =
               Engine.add_player("Brad", "Jennifer", her)
    end
  end

  describe "Engine.position_island/5" do
    test "positions an island" do
      her = self()
      him = self()
      Engine.new_game("Bonnie", her)
      Engine.add_player("Bonnie", "Clyde", him)

      assert %Tally{response: {:ok, :island_positioned}} =
               Engine.position_island("Bonnie", :player2, :atoll, 1, 1)
    end

    test "fails to position an island" do
      her = self()
      him = self()
      Engine.new_game("Sally", her)
      Engine.add_player("Sally", "Harry", him)
      Engine.position_island("Sally", :player2, :atoll, 1, 1)

      assert %Tally{response: {:error, :overlapping_island}} =
               Engine.position_island("Sally", :player2, :dot, 1, 1)
    end
  end

  describe "Engine.position_all_islands/2" do
    test "positions all islands" do
      him = self()
      her = self()
      Engine.new_game("Samson", him)
      Engine.add_player("Samson", "Delilah", her)

      assert %Tally{response: {:ok, :all_islands_positioned}} =
               Engine.position_all_islands("Samson", :player2)
    end
  end

  describe "Engine.set_islands/2" do
    test "fails to set islands" do
      him = self()
      her = self()
      Engine.new_game("Adam", him)
      Engine.add_player("Adam", "Eve", her)
      Engine.position_island("Adam", :player2, :atoll, 1, 1)

      assert %Tally{response: {:error, :not_all_islands_positioned}} =
               Engine.set_islands("Adam", :player2)
    end

    test "sets islands" do
      her = self()
      him = self()
      Engine.new_game("Mary", her)
      Engine.add_player("Mary", "Joseph", him)
      Engine.position_all_islands("Mary", :player2)

      assert %Tally{response: {:ok, :islands_set}} =
               Engine.set_islands("Mary", :player2)
    end
  end

  describe "Engine.guess_coord/4" do
    test "fails to make a guess" do
      him = self()
      her = self()
      Engine.new_game("Caesar", him)
      Engine.add_player("Caesar", "Cleopatra", her)
      Engine.position_all_islands("Caesar", :player1)
      Engine.position_all_islands("Caesar", :player2)
      Engine.set_islands("Caesar", :player2)

      assert %Tally{response: {:error, :not_both_players_islands_set}} =
               Engine.guess_coord("Caesar", :player2, 9, 9)
    end

    test "makes a guess" do
      him = self()
      her = self()
      Engine.new_game("Tristan", him)
      Engine.add_player("Tristan", "Isolde", her)
      Engine.position_island("Tristan", :player2, :atoll, 1, 1)
      Engine.position_island("Tristan", :player2, :l_shape, 3, 7)
      Engine.position_island("Tristan", :player2, :s_shape, 6, 2)
      Engine.position_island("Tristan", :player2, :square, 9, 5)
      Engine.position_island("Tristan", :player2, :dot, 9, 9)
      Engine.set_islands("Tristan", :player2)
      Engine.position_all_islands("Tristan", :player1)
      Engine.set_islands("Tristan", :player1)

      assert %Tally{response: {:hit, :dot, :no_win}} =
               Engine.guess_coord("Tristan", :player1, 9, 9)
    end
  end

  describe "Engine.tally/2" do
    test "returns tally of game" do
      him = self()
      Engine.new_game("Jim", him)
      assert %Tally{game_state: :initialized} = Engine.tally("Jim", :player1)
    end
  end
end
