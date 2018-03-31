defmodule Islands.Engine.GridTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Islands.Engine.{Board, Coord, Grid, Guesses, Island}

  doctest Grid

  # setup_all do
  #   {:ok, atoll_coord} = Coord.new(1, 1)
  #   {:ok, atoll_hit} = Coord.new(1, 2)
  #   {:ok, atoll} = Island.new(:atoll, atoll_coord)

  #   {:hit, :none, :no_win, board} =
  #     Board.new()
  #     |> Board.position_island(atoll)
  #     |> Board.guess(atoll_hit)

  #   guesses =
  #     Guesses.new()
  #     |> Guesses.add(:miss, atoll_coord)
  #     |> Guesses.add(:hit, atoll_hit)

  #   {:ok, board: board, guesses: guesses}
  # end

  # describe "Grid.new/0" do
  #   test "returns a map of maps" do
  #     %{1 => row_1} = Grid.new()

  #     assert row_1 == %{
  #              1 => nil,
  #              2 => nil,
  #              3 => nil,
  #              4 => nil,
  #              5 => nil,
  #              6 => nil,
  #              7 => nil,
  #              8 => nil,
  #              9 => nil,
  #              10 => nil
  #            }
  #   end
  # end

  # describe "Grid.new/1" do
  #   test "returns a board grid", %{board: board} do
  #     %{1 => row_1} = Grid.new(board)

  #     assert row_1 == %{
  #              1 => :atoll,
  #              2 => :atoll_hit,
  #              3 => nil,
  #              4 => nil,
  #              5 => nil,
  #              6 => nil,
  #              7 => nil,
  #              8 => nil,
  #              9 => nil,
  #              10 => nil
  #            }
  #   end

  #   test "returns a guesses grid", %{guesses: guesses} do
  #     %{1 => row_1} = Grid.new(guesses)

  #     assert row_1 == %{
  #              1 => :miss,
  #              2 => :hit,
  #              3 => nil,
  #              4 => nil,
  #              5 => nil,
  #              6 => nil,
  #              7 => nil,
  #              8 => nil,
  #              9 => nil,
  #              10 => nil
  #            }
  #   end
  # end
end
