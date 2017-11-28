defmodule IslandsEngine.Board do
  @moduledoc """
  Board module...
  """

  alias IslandsEngine.{Coordinate, Island}

  @type t :: map

  @spec new() :: t
  def new(), do: %{}

  @spec position_island(t, Island.type, Island.t) :: t | {:error, atom}
  def position_island(board, type, %Island{} = island) do
    overlaps_existing_island?(board, type, island) &&
      {:error, :overlapping_island} ||
      Map.put(board, type, island)
  end

  @spec all_islands_positioned?(t) :: boolean
  def all_islands_positioned?(board) do
    Island.types() |> Enum.all?(& &1 in board.keys())
  end

  def guess(board, %Coordinate{} = coordinate) do
    board
    |> check_all_islands(coordinate)
    |> guess_response(board)
  end

  ## Private functions

  @spec overlaps_existing_island?(t, Island.type, Island.t) :: boolean
  defp overlaps_existing_island?(board, new_type, new_island) do
    Enum.any?(board, fn {type, island} ->
      type != new_type and Island.overlaps?(island, new_island)
    end)
  end

  defp check_all_islands(board, coordinate) do
    Enum.find_value(board, :miss, fn {key, island} ->
      case Island.guess(island, coordinate) do
        {:hit, island} -> {key, island}
        :miss -> false
      end
    end)
  end

  defp guess_response({type, island}, board) do
    board = %{board | type => island}
    {:hit, forest_check(board, type), win_check(board), board}
  end
  defp guess_response(:miss, board), do: {:miss, :none, :no_win, board}

  @spec forest_check(t, Island.type) :: Island.type | :none
  defp forest_check(board, type), do: forested?(board, type) && type || :none

  @spec forested?(t, Island.type) :: boolean
  defp forested?(board, type) do
    board |> Map.fetch!(type) |> Island.forested?()
  end

  @spec win_check(t) :: boolean
  defp win_check(board), do: all_forested?(board) && :win || :no_win

  @spec all_forested?(t) :: boolean
  defp all_forested?(board) do
    Enum.all?(board, fn {_type, island} -> Island.forested?(island) end)
  end
end
