defmodule Islands.Engine.Tally.Count do
  @moduledoc false

  import MapSet, only: [size: 1]

  alias Islands.Engine.{Board, Guesses, Island}

  @spec board_hits(Board.t()) :: non_neg_integer
  def board_hits(%Board{islands: islands} = _board) do
    Enum.reduce(islands, 0, fn {_type, %Island{hits: hits}}, sum ->
      size(hits) + sum
    end)
  end

  @spec board_misses(Board.t()) :: non_neg_integer
  def board_misses(%Board{misses: misses} = _board), do: size(misses)

  @spec guesses_hits(Guesses.t()) :: non_neg_integer
  def guesses_hits(%Guesses{hits: hits} = _guesses), do: size(hits)

  @spec guesses_misses(Guesses.t()) :: non_neg_integer
  def guesses_misses(%Guesses{misses: misses} = _guesses), do: size(misses)
end
