defmodule Islands.Engine.TallyTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Islands.Engine.Tally

  doctest Tally

  describe "Tally.new/2" do
    # test "returns %Tally{} given valid args" do
    #   assert Tally.new() == %Tally{board: Grid.new(), guesses: Grid.new()}
    # end

    # test "returns {:error, ...} given invalid args" do
    #   assert Tally.new('Jim') == {:error, :invalid_tally_args}
    # end
  end
end
