defmodule Islands.Engine.Tally.Score do
  @moduledoc false

  import MapSet, only: [size: 1]

  alias Islands.Engine.{Board, Guesses, Island}

  @spec for(Board.t() | Guesses.t()) :: {non_neg_integer, non_neg_integer}
  def for(board_or_guesses)

  def for(%Board{islands: islands, misses: misses} = _board) do
    {Enum.reduce(islands, 0, fn {_type, %Island{hits: hits}}, sum ->
       size(hits) + sum
     end), size(misses)}
  end

  def for(%Guesses{hits: hits, misses: misses} = _guesses) do
    {size(hits), size(misses)}
  end
end
