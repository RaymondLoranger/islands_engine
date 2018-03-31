defmodule Islands.Engine.BoardTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Islands.Engine.{Board, Coord, Island}

  doctest Board

  # setup_all do
  #   # See picture of the game in Functional Web Development on page 13...
  #   {:ok, square_coord} = Coord.new(9, 5)
  #   {:ok, dot_coord} = Coord.new(9, 9)
  #   {:ok, l_shape_coord} = Coord.new(3, 7)
  #   {:ok, s_shape_coord} = Coord.new(6, 2)
  #   {:ok, atoll_coord} = Coord.new(1, 1)
  #   {:ok, dot_overlap_coord} = Coord.new(3, 2)

  #   {:ok, square} = Island.new(:square, square_coord)
  #   {:ok, dot} = Island.new(:dot, dot_coord)
  #   {:ok, l_shape} = Island.new(:l_shape, l_shape_coord)
  #   {:ok, s_shape} = Island.new(:s_shape, s_shape_coord)
  #   {:ok, atoll} = Island.new(:atoll, atoll_coord)
  #   {:ok, dot_overlap} = Island.new(:dot, dot_overlap_coord)

  #   incomplete =
  #     Board.new()
  #     |> Board.position_island(square)
  #     |> Board.position_island(dot)

  #   complete =
  #     incomplete
  #     |> Board.position_island(l_shape)
  #     |> Board.position_island(s_shape)
  #     |> Board.position_island(atoll)

  #   coords = %{
  #     square: square_coord,
  #     dot: dot_coord,
  #     l_shape: l_shape_coord,
  #     s_shape: s_shape_coord,
  #     atoll: atoll_coord,
  #     dot_overlap: dot_overlap_coord
  #   }

  #   islands = %{
  #     square: square,
  #     dot: dot,
  #     l_shape: l_shape,
  #     s_shape: s_shape,
  #     atoll: atoll,
  #     dot_overlap: dot_overlap
  #   }

  #   boards = %{incomplete: incomplete, complete: complete}

  #   {:ok, coords: coords, islands: islands, boards: boards}
  # end

  # describe "Board.position_island/2" do
  #   test "returns a board given valid args", %{islands: islands} do
  #     square = islands.square
  #     board = Board.new() |> Board.position_island(square)
  #     %{square: %Island{} = island} = board
  #     assert ^square = island
  #   end

  #   test "returns {:error, ...} on overlapping island", %{islands: islands} do
  #     atoll = islands.atoll
  #     dot_overlap = islands.dot_overlap
  #     %{} = board = Board.new() |> Board.position_island(atoll)

  #     assert Board.position_island(board, dot_overlap) ==
  #              {:error, :overlapping_island}
  #   end
  # end

  # describe "Board.all_islands_positioned?/1" do
  #   test "all islands positioned", %{boards: boards} do
  #     assert Board.all_islands_positioned?(boards.complete)
  #   end

  #   test "not all islands positioned", %{boards: boards} do
  #     refute Board.all_islands_positioned?(boards.incomplete)
  #   end
  # end

  # describe "Board.guess/2" do
  #   test "detects a hit guess", %{coords: coords, boards: boards} do
  #     response = Board.guess(boards.complete, coords.dot)
  #     assert {:hit, :dot, :no_win, %{} = _board} = response
  #   end

  #   test "detects a miss guess", %{coords: coords, boards: boards} do
  #     complete = boards.complete
  #     response = Board.guess(complete, coords.s_shape)
  #     assert {:miss, :none, :no_win, %{} = board} = response
  #     assert ^complete = board
  #   end

  #   test "detects a win guess", %{coords: coords, boards: boards} do
  #     square = boards.incomplete.square
  #     square = %{square | hits: square.coords}

  #     response =
  #       boards.incomplete
  #       |> Board.position_island(square)
  #       |> Board.guess(coords.dot)

  #     assert {:hit, :dot, :win, %{} = _board} = response
  #   end
  # end
end
