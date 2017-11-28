defmodule IslandsEngine.BoardTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias IslandsEngine.{Board, Coordinate, Island}

  doctest Board

  describe "Board.position_island/3" do
    test "returns {:ok, ...} given valid args" do
      board = Board.new()
      {:ok, square_coordinate} = Coordinate.new(1, 1)
      {:ok, square} = Island.new(:square, square_coordinate)
      board = Board.position_island(board, :square, square)
      assert %{square: %Island{}} = board
    end
  end
end
