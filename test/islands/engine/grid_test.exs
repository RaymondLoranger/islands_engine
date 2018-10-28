defmodule Islands.Engine.GridTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Islands.Engine.{Board, Coord, Grid, Guesses, Island}

  doctest Grid

  setup_all do
    {:ok, atoll_coord} = Coord.new(1, 1)
    {:ok, atoll_hit} = Coord.new(1, 2)
    {:ok, board_miss} = Coord.new(1, 3)
    {:ok, hit} = Coord.new(1, 4)
    {:ok, miss} = Coord.new(1, 5)
    {:ok, atoll} = Island.new(:atoll, atoll_coord)

    {:hit, :none, :no_win, board} =
      Board.new()
      |> Board.position_island(atoll)
      |> Board.guess(atoll_hit)

    {:miss, :none, :no_win, board} = Board.guess(board, board_miss)

    guesses =
      Guesses.new()
      |> Guesses.add(:hit, hit)
      |> Guesses.add(:miss, miss)

    {:ok, board: board, guesses: guesses}
  end

  describe "Grid.new/0" do
    test "returns a map of maps" do
      %{1 => row_1, 2 => row_2, 10 => row_10} = Grid.new()

      assert row_1 == %{
               1 => nil,
               2 => nil,
               3 => nil,
               4 => nil,
               5 => nil,
               6 => nil,
               7 => nil,
               8 => nil,
               9 => nil,
               10 => nil
             }

      assert row_2 == row_10
      assert row_10 |> Map.values() |> Enum.all?(&is_nil/1)
    end
  end

  describe "Grid.new/1" do
    test "returns a board grid", %{board: board} do
      %{1 => row_1, 2 => row_2, 10 => row_10} = Grid.new(board)

      assert row_1 == %{
               1 => :atoll,
               2 => :atoll_hit,
               3 => :board_miss,
               4 => nil,
               5 => nil,
               6 => nil,
               7 => nil,
               8 => nil,
               9 => nil,
               10 => nil
             }

      assert row_2 == %{
               1 => nil,
               2 => :atoll,
               3 => nil,
               4 => nil,
               5 => nil,
               6 => nil,
               7 => nil,
               8 => nil,
               9 => nil,
               10 => nil
             }

      assert row_10 |> Map.values() |> Enum.all?(&is_nil/1)
    end

    test "returns a guesses grid", %{guesses: guesses} do
      %{1 => row_1, 2 => row_2, 10 => row_10} = Grid.new(guesses)

      assert row_1 == %{
               1 => nil,
               2 => nil,
               3 => nil,
               4 => :hit,
               5 => :miss,
               6 => nil,
               7 => nil,
               8 => nil,
               9 => nil,
               10 => nil
             }

      assert row_2 == row_10
      assert row_10 |> Map.values() |> Enum.all?(&is_nil/1)
    end
  end

  describe "Grid.to_maps/2" do
    test "converts a grid to a list of maps", %{board: board} do
      [row_1, row_2 | _] = board |> Grid.new() |> Grid.to_maps(& &1)

      assert row_1 == %{
               "row" => 1,
               1 => :atoll,
               2 => :atoll_hit,
               3 => :board_miss,
               4 => nil,
               5 => nil,
               6 => nil,
               7 => nil,
               8 => nil,
               9 => nil,
               10 => nil
             }

      assert row_2 == %{
               "row" => 2,
               1 => nil,
               2 => :atoll,
               3 => nil,
               4 => nil,
               5 => nil,
               6 => nil,
               7 => nil,
               8 => nil,
               9 => nil,
               10 => nil
             }
    end
  end
end
