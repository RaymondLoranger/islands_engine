defmodule IslandsEngine.GuessesTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias IslandsEngine.Guesses

  doctest Guesses

  describe "Guesses.new/0" do
    test "returns a struct" do
      assert %Guesses{} = Guesses.new()
    end
  end
end
