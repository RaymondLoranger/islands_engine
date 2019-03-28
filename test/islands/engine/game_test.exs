defmodule Islands.Engine.GameTest do
  use ExUnit.Case, async: true

  alias Islands.Engine.Game
  alias Islands.Player

  doctest Game

  describe "Game.new/3" do
    test "returns %Game{} given valid args" do
      me = self()

      assert %Game{name: "Aveline", player1: %Player{name: "Jordan", pid: me}} =
               Game.new("Aveline", "Jordan", me)
    end

    test "returns {:error, ...} given invalid args" do
      assert Game.new("Aveline", "Jordan", :pid) == {:error, :invalid_game_args}
    end
  end
end
