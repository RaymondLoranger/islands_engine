defmodule Islands.Engine.PlayerTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Islands.Engine.{Board, Guesses, Player}

  doctest Player

  describe "Player.new/1" do
    test "returns %Player{} given valid args" do
      assert Player.new("Ben") == %Player{
               name: "Ben",
               pid: nil,
               board: Board.new(),
               guesses: Guesses.new()
             }
    end

    test "returns {:error, ...} given invalid args" do
      assert Player.new('Jim') == {:error, :invalid_player_args}
    end
  end

  describe "Player.update_player_pid/2" do
    test "updates the pid of a player" do
      this = self()
      carl = Player.new("Carl")

      assert Player.update_player_pid(carl, this) == %Player{
               name: "Carl",
               pid: this,
               board: Board.new(),
               guesses: Guesses.new()
             }
    end
  end
end
