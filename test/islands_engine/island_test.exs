defmodule IslandsEngine.IslandTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias IslandsEngine.{Coordinate, Island}

  doctest Island

  describe "Island.new/2" do
    test "returns {:ok, ...} given valid args" do
      {:ok, coordinate} = Coordinate.new(4, 6)
      assert {:ok, %Island{}} = Island.new(:l_shape, coordinate)
    end

    test "returns {:error, ...} given bad type" do
      {:ok, coordinate} = Coordinate.new(4, 6)
      assert {:error, :invalid_island_type} = Island.new(:wrong, coordinate)
    end

    test "returns {:error, ...} given bad coordinate" do
      {:ok, coordinate} = Coordinate.new(10, 10)
      assert {:error, :invalid_coordinate} = Island.new(:l_shape, coordinate)
    end
  end
end
