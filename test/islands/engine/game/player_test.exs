defmodule Islands.Engine.Game.PlayerTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Islands.Engine.Game.Player
  alias Islands.Engine.{Board, Guesses}

  doctest Player

  describe "Player.new/1" do
    test "returns %Player{} given valid args" do
      me = self()

      assert Player.new("Sue", me) == %Player{
               name: "Sue",
               pid: me,
               board: Board.new(),
               guesses: Guesses.new()
             }

      assert Player.new("Ben", nil) == %Player{
               name: "Ben",
               pid: nil,
               board: Board.new(),
               guesses: Guesses.new()
             }
    end

    test "returns {:error, ...} given invalid args" do
      assert Player.new('Jim', nil) == {:error, :invalid_player_args}
    end
  end
end
