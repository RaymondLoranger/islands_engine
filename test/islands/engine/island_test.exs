defmodule Islands.Engine.IslandTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Islands.Engine.{Coord, Island}

  doctest Island

  setup_all do
    {:ok, square_coord} = Coord.new(1, 1)
    {:ok, dot_coord} = Coord.new(1, 2)
    {:ok, l_shape_coord} = Coord.new(6, 6)

    {:ok, square} = Island.new(:square, square_coord)
    {:ok, dot} = Island.new(:dot, dot_coord)
    {:ok, l_shape} = Island.new(:l_shape, l_shape_coord)

    coords = %{
      square: square_coord,
      dot: dot_coord,
      l_shape: l_shape_coord
    }

    islands = %{
      square: square,
      dot: dot,
      l_shape: l_shape
    }

    {:ok, coords: coords, islands: islands}
  end

  describe "Island.new/2" do
    test "returns {:ok, ...} given valid args" do
      {:ok, coord} = Coord.new(4, 6)
      assert {:ok, %Island{}} = Island.new(:l_shape, coord)
    end

    test "returns {:error, ...} given bad island type" do
      {:ok, coord} = Coord.new(9, 3)
      assert {:error, :invalid_island_type} = Island.new(:wrong, coord)
    end

    test "returns {:error, ...} given invalid origin" do
      {:ok, coord} = Coord.new(10, 10)
      assert {:error, :invalid_origin} = Island.new(:l_shape, coord)
    end

    test "returns {:error, ...} given improper origin" do
      coord = %{row: 3, col: 7}
      assert {:error, :improper_origin} = Island.new(:l_shape, coord)
    end
  end

  describe "Island.overlaps?/2" do
    test "islands overlapping", %{islands: islands} do
      assert Island.overlaps?(islands.square, islands.dot)
    end

    test "islands not overlapping", %{islands: islands} do
      refute Island.overlaps?(islands.square, islands.l_shape)
    end
  end

  describe "Island.guess/2" do
    test "good guess", %{islands: islands, coords: coords} do
      assert {:hit, %Island{}} = Island.guess(islands.dot, coords.dot)
    end

    test "bad guess", %{islands: islands} do
      {:ok, coord} = Coord.new(3, 4)
      assert :miss = Island.guess(islands.dot, coord)
    end
  end

  describe "Island.forested?/1" do
    test "island forested", %{islands: islands, coords: coords} do
      {:hit, dot} = Island.guess(islands.dot, coords.dot)
      assert Island.forested?(dot)
    end

    test "island not forested?", %{islands: islands} do
      {:ok, coord} = Coord.new(3, 4)
      assert Island.guess(islands.dot, coord) == :miss
      refute Island.forested?(islands.dot)
    end
  end
end
