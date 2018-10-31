defmodule Islands.Engine.Game.TallyTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Islands.Engine.Game.{Grid, Tally}
  alias Islands.Engine.Game

  doctest Tally

  describe "Tally.new/2" do
    test "returns %Tally{} given valid args" do
      game = Game.new("Tetra", "Jay", self())

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
      game = Game.new("Jade", "John", self())
      assert Tally.new(game, :player3) == {:error, :invalid_tally_args}
    end
  end
end
