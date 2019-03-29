defmodule Islands.Engine.Game.TallyTest do
  use ExUnit.Case, async: true

  alias Islands.Engine.Game.Tally
  alias Islands.Engine.Game
  alias Islands.{Board, Guesses, Score}

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
        board_score: board_score,
        guesses: guesses,
        guesses_score: guesses_score
      } = Tally.new(game, :player1)

      assert board == Board.new() and guesses == Guesses.new()
      assert board_score == %Score{hits: 0, misses: 0, forested_types: []}
      assert guesses_score == %Score{hits: 0, misses: 0, forested_types: []}
    end

    test "returns {:error, ...} given invalid args" do
      game = Game.new("Jade", "John", self())
      assert Tally.new(game, :player3) == {:error, :invalid_tally_args}
    end
  end
end
