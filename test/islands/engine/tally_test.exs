defmodule Islands.Engine.TallyTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Islands.Engine.{Game, Grid, Tally}

  doctest Tally

  describe "Tally.new/2" do
    test "returns %Tally{} given valid args" do
      game = Game.new("Jay")

      %Tally{
        game_state: :initialized,
        player1_state: :islands_not_set,
        player2_state: :islands_not_set,
        request: {},
        response: {},
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
