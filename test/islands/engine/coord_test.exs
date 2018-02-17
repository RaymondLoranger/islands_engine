defmodule Islands.Engine.CoordTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Islands.Engine.Coord

  doctest Coord

  describe "Coord.new/2" do
    test "returns {:ok, ...} given valid args" do
      assert {:ok, %Coord{}} = Coord.new(1, 10)
    end

    test "returns {:error, ...} given bad args" do
      assert {:error, :invalid_coordinate} = Coord.new(0, 10)
    end
  end
end
