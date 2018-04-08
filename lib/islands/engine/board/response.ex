defmodule Islands.Engine.Board.Response do
  @moduledoc false

  alias Islands.Engine.{Board, Coord, Island}

  @type t :: {:hit | :miss, Island.type() | :none, :no_win | :win, Board.t()}

  @spec check(Board.t(), Coord.t()) :: {:hit, Island.t()} | {:miss, Coord.t()}
  def check(%Board{} = board, %Coord{} = guess) do
    Enum.find_value(board.islands, {:miss, guess}, fn {_type, island} ->
      case Island.guess(island, guess) do
        {:hit, island} -> {:hit, island}
        :miss -> false
      end
    end)
  end

  @spec to({:hit, Island.t()} | {:miss, Coord.t()}, Board.t()) :: t
  def to({:hit, island}, board) do
    board = put_in(board.islands[island.type], island)
    {:hit, forest_check(board, island), win_check(board), board}
  end

  def to({:miss, guess}, board) do
    board = update_in(board.misses, &MapSet.put(&1, guess))
    {:miss, :none, :no_win, board}
  end

  ## Private functions

  @spec forest_check(Board.t(), Island.t()) :: Island.type() | :none
  defp forest_check(board, %Island{type: type} = _island) do
    if Island.forested?(board.islands[type]), do: type, else: :none
  end

  @spec win_check(Board.t()) :: :win | :no_win
  defp win_check(board), do: if(all_forested?(board), do: :win, else: :no_win)

  @spec all_forested?(Board.t()) :: boolean
  defp all_forested?(%Board{islands: islands} = _board) do
    Enum.all?(islands, fn {_type, island} -> Island.forested?(island) end)
  end
end
