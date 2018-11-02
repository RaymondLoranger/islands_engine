defmodule Islands.EngineTest do
  use ExUnit.Case, async: true

  alias Islands.Engine.Game.Tally
  alias Islands.Engine

  doctest Engine

  describe "Engine.new_game/2" do
    test "starts a new game" do
      me = self()
      {:ok, game_id} = Engine.new_game("Arcade", "Meg", me)
      assert is_pid(game_id)
    end

    test "fails to start a game" do
      me = self()
      {:ok, game_id} = Engine.new_game("Ad lib", "Mel", me)

      assert {:error, {:already_started, ^game_id}} =
               Engine.new_game("Ad lib", "Mea", me)
    end
  end

  describe "Engine.end_game/1" do
    test "ends a game" do
      me = self()
      Engine.new_game("Magic", "Ben", me)
      assert Engine.end_game("Magic") == :ok
    end
  end

  describe "Engine.stop_game/2" do
    test "fails to stop a game" do
      him = self()
      her = self()
      Engine.new_game("Skyfall", "Tarzan", him)
      Engine.add_player("Skyfall", "Jane", her)
      Engine.position_all_islands("Skyfall", :player2)
      Engine.set_islands("Skyfall", :player2)

      assert %Tally{response: {:error, :not_both_players_islands_set}} =
               Engine.stop_game("Skyfall", :player2)
    end

    test "stops a game" do
      him = self()
      her = self()
      Engine.new_game("Songs", "Sonny", him)
      Engine.add_player("Songs", "Cher", her)
      Engine.position_all_islands("Songs", :player2)
      Engine.set_islands("Songs", :player2)
      Engine.position_all_islands("Songs", :player1)
      Engine.set_islands("Songs", :player1)

      assert %Tally{response: {:ok, :stopping}} =
               Engine.stop_game("Songs", :player2)
    end
  end

  describe "Engine.add_player/3" do
    test "adds second player" do
      him = self()
      her = self()
      Engine.new_game("Love", "Romeo", him)

      assert %Tally{response: {:ok, :player2_added}} =
               Engine.add_player("Love", "Juliet", her)
    end

    test "fails to add second player" do
      him = self()
      her = self()
      Engine.new_game("Movies", "Brad", him)
      Engine.add_player("Movies", "Angelina", her)

      assert %Tally{response: {:error, :player2_already_added}} =
               Engine.add_player("Movies", "Jennifer", her)
    end
  end

  describe "Engine.position_island/5" do
    test "positions an island" do
      her = self()
      him = self()
      Engine.new_game("Chewbacca", "Bonnie", her)
      Engine.add_player("Chewbacca", "Clyde", him)

      assert %Tally{response: {:ok, :island_positioned}} =
               Engine.position_island("Chewbacca", :player2, :atoll, 1, 1)
    end

    test "fails to position an island" do
      her = self()
      him = self()
      Engine.new_game("Frogger", "Sally", her)
      Engine.add_player("Frogger", "Harry", him)
      Engine.position_island("Frogger", :player2, :atoll, 1, 1)

      assert %Tally{response: {:error, :overlapping_island}} =
               Engine.position_island("Frogger", :player2, :dot, 1, 1)
    end
  end

  describe "Engine.position_all_islands/2" do
    test "positions all islands" do
      him = self()
      her = self()
      Engine.new_game("Bible", "Samson", him)
      Engine.add_player("Bible", "Delilah", her)

      assert %Tally{response: {:ok, :all_islands_positioned}} =
               Engine.position_all_islands("Bible", :player2)
    end
  end

  describe "Engine.set_islands/2" do
    test "fails to set islands" do
      him = self()
      her = self()
      Engine.new_game("Eden", "Adam", him)
      Engine.add_player("Eden", "Eve", her)
      Engine.position_island("Eden", :player2, :atoll, 1, 1)

      assert %Tally{response: {:error, :not_all_islands_positioned}} =
               Engine.set_islands("Eden", :player2)
    end

    test "sets islands" do
      her = self()
      him = self()
      Engine.new_game("Holy", "Mary", her)
      Engine.add_player("Holy", "Joseph", him)
      Engine.position_all_islands("Holy", :player2)

      assert %Tally{response: {:ok, :islands_set}} =
               Engine.set_islands("Holy", :player2)
    end
  end

  describe "Engine.guess_coord/4" do
    test "fails to make a guess" do
      him = self()
      her = self()
      Engine.new_game("Egypt", "Caesar", him)
      Engine.add_player("Egypt", "Cleopatra", her)
      Engine.position_all_islands("Egypt", :player1)
      Engine.position_all_islands("Egypt", :player2)
      Engine.set_islands("Egypt", :player2)

      assert %Tally{response: {:error, :not_both_players_islands_set}} =
               Engine.guess_coord("Egypt", :player2, 9, 9)
    end

    test "makes a guess" do
      him = self()
      her = self()
      Engine.new_game("Romance", "Tristan", him)
      Engine.add_player("Romance", "Isolde", her)
      Engine.position_island("Romance", :player2, :atoll, 1, 1)
      Engine.position_island("Romance", :player2, :l_shape, 3, 7)
      Engine.position_island("Romance", :player2, :s_shape, 6, 2)
      Engine.position_island("Romance", :player2, :square, 9, 5)
      Engine.position_island("Romance", :player2, :dot, 9, 9)
      Engine.set_islands("Romance", :player2)
      Engine.position_all_islands("Romance", :player1)
      Engine.set_islands("Romance", :player1)

      assert %Tally{response: {:hit, :dot, :no_win}} =
               Engine.guess_coord("Romance", :player1, 9, 9)
    end
  end

  describe "Engine.tally/2" do
    test "returns tally of game" do
      him = self()
      Engine.new_game("Jungle", "Jim", him)
      assert %Tally{game_state: :initialized} = Engine.tally("Jungle", :player1)
    end
  end
end
