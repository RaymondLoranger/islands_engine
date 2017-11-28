defmodule IslandsEngine.CoordinateTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias IslandsEngine.Coordinate

  doctest Coordinate

  describe "Coordinate.new/2" do
    test "returns {:ok, ...} given valid args" do
      assert {:ok, %Coordinate{}} = Coordinate.new(1, 10)
    end

    test "returns {:error, ...} given bad args" do
      assert {:error, :invalid_coordinate} = Coordinate.new(0, 10)
    end
  end
end
