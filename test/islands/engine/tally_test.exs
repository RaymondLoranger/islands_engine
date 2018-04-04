defmodule Islands.Engine.TallyTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Islands.Engine.{Game, Grid, Tally}

  doctest Tally

  describe "Tally.new/2" do
    test "returns %Tally{} given valid args" do
      game = Game.new("Jay")

      assert %Tally{
               game_state: :initialized,
               board: board,
               guesses: guesses
             } = Tally.new(game, :player1)

      assert board == Grid.new() and guesses == Grid.new()
    end

    test "returns {:error, ...} given invalid args" do
      game = Game.new("John")
      assert Tally.new(game, :player3) == {:error, :invalid_tally_args}
    end
  end
end
