defmodule Islands.Engine.Board do
  # @moduledoc """
  # Board module...
  # """
  @moduledoc false

  use PersistConfig

  alias Islands.Engine.{Coord, Island}

  @type hit_forested_no_win :: {:hit, Island.type(), :no_win, t}
  @type hit_forested_none :: {:hit, :none, :no_win, t}
  @type hit_forested_win :: {:hit, Island.type(), :win, t}
  @type hit :: hit_forested_no_win | hit_forested_none | hit_forested_win
  @type miss :: {:miss, :none, :no_win, t}
  @type response :: hit | miss
  @type t :: map

  @types Application.get_env(@app, :island_types)

  @spec new() :: t
  def new(), do: %{}

  @spec position_island(t, Island.t()) :: t | {:error, atom}
  def position_island(%{} = board, %Island{} = island) do
    if overlaps_other_islands?(board, island),
      do: {:error, :overlapping_island},
      else: Map.put(board, island.type, island)
  end

  @spec all_islands_positioned?(t) :: boolean
  def all_islands_positioned?(%{} = board) do
    Enum.all?(@types, &Map.has_key?(board, &1))
  end

  @spec guess(t, Coord.t()) :: response
  def guess(%{} = board, %Coord{} = guess) do
    board |> check_all_islands(guess) |> guess_response(board)
  end

  ## Private functions

  @spec overlaps_other_islands?(t, Island.t()) :: boolean
  defp overlaps_other_islands?(board, new_island) do
    Enum.any?(board, fn {type, island} ->
      type != new_island.type and Island.overlaps?(island, new_island)
    end)
  end

  @spec check_all_islands(t, Coord.t()) :: {:hit, Island.t()} | :miss
  defp check_all_islands(board, guess) do
    Enum.find_value(board, :miss, fn {_type, island} ->
      case Island.guess(island, guess) do
        {:hit, island} -> {:hit, island}
        :miss -> false
      end
    end)
  end

  @spec guess_response({:hit, Island.t()} | :miss, t) :: response
  defp guess_response({:hit, island}, board) do
    board = %{board | island.type => island}
    {:hit, forest_check(board, island), win_check(board), board}
  end

  defp guess_response(:miss, board), do: {:miss, :none, :no_win, board}

  @spec forest_check(t, Island.t()) :: Island.type() | :none
  defp forest_check(board, island) do
    if Island.forested?(board[island.type]), do: island.type, else: :none
  end

  @spec win_check(t) :: :win | :no_win
  defp win_check(board) do
    if all_forested?(board), do: :win, else: :no_win
  end

  @spec all_forested?(t) :: boolean
  defp all_forested?(board) do
    Enum.all?(board, fn {_type, island} -> Island.forested?(island) end)
  end
end
