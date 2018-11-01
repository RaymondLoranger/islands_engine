defmodule Islands.Engine.Game.Tally.Score do
  alias Islands.Engine.{Board, Guesses}

  @spec for(Board.t() | Guesses.t()) ::
          {atom, non_neg_integer, non_neg_integer} | {:error, atom}
  def for(board_or_guesses)

  def for(%Board{islands: islands, misses: misses} = _board) do
    {:board_score,
     islands |> Map.values() |> Enum.map(&MapSet.size(&1.hits)) |> Enum.sum(),
     MapSet.size(misses)}
  end

  def for(%Guesses{hits: hits, misses: misses} = _guesses),
    do: {:guesses_score, MapSet.size(hits), MapSet.size(misses)}

  def for(_board_or_guesses), do: {:error, :invalid_score_args}
end
