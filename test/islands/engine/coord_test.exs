defmodule Islands.Engine.CoordTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Islands.Engine.Coord

  doctest Coord

  describe "Coord.new/2" do
    test "returns {:ok, ...} given valid args" do
      assert Coord.new(1, 10) == {:ok, %Coord{row: 1, col: 10}}
    end

    test "returns {:error, ...} given invalid args" do
      assert Coord.new(0, 10) == {:error, :invalid_coordinate}
      assert Coord.new(-1, 2) == {:error, :invalid_coordinate}
      assert Coord.new("1", "2") == {:error, :invalid_coordinate}
    end
  end
end
