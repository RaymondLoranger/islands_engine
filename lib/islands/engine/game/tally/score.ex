defmodule Islands.Engine.Game.Tally.Score do
  @moduledoc "Convenience module for client application."

  alias __MODULE__
  alias Islands.Engine.{Board, Guesses}

  @enforce_keys [:type, :hits, :misses]
  defstruct [:type, :hits, :misses]

  @type t :: %Score{
          type: :board | :guesses,
          hits: non_neg_integer,
          misses: non_neg_integer
        }

  @spec new(Board.t() | Guesses.t()) :: t
  def new(board_or_guesses)

  def new(%Board{islands: islands, misses: misses} = _board) do
    %Score{
      type: :board,
      hits:
        islands
        |> Map.values()
        |> Enum.map(&MapSet.size(&1.hits))
        |> Enum.sum(),
      misses: MapSet.size(misses)
    }
  end

  def new(%Guesses{hits: hits, misses: misses} = _guesses) do
    %Score{
      type: :guesses,
      hits: MapSet.size(hits),
      misses: MapSet.size(misses)
    }
  end

  def new(_board_or_guesses), do: {:error, :invalid_score_args}
end
