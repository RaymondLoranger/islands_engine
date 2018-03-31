defmodule Islands.Engine.Board do
  @moduledoc false

  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.{Coord, Island}

  @enforce_keys [:islands, :misses]
  defstruct [:islands, :misses]

  @type islands :: %{Island.type() => Island.t()}
  @type response :: hit | miss
  @type t :: %Board{islands: islands, misses: Island.coords()}

  @typep hit :: hit_forested_no_win | hit_forested_none | hit_forested_win
  @typep hit_forested_no_win :: {:hit, Island.type(), :no_win, t}
  @typep hit_forested_none :: {:hit, :none, :no_win, t}
  @typep hit_forested_win :: {:hit, Island.type(), :win, t}
  @typep miss :: {:miss, :none, :no_win, t}

  @island_types Application.get_env(@app, :island_types)

  @spec new() :: t
  def new(), do: %Board{islands: %{}, misses: MapSet.new()}

  @spec position_island(t, Island.t()) :: t | {:error, atom}
  def position_island(%Board{} = board, %Island{} = island) do
    if overlaps_other_island?(board.islands, island),
      do: {:error, :overlapping_island},
      else: put_in(board.islands[island.type], island)
  end

  @spec all_islands_positioned?(t) :: boolean
  def all_islands_positioned?(%Board{} = board) do
    Enum.all?(@island_types, &Map.has_key?(board.islands, &1))
  end

  @spec guess(t, Coord.t()) :: response
  def guess(%Board{} = board, %Coord{} = guess) do
    board |> check_islands(guess) |> response(board)
  end

  ## Private functions

  @spec overlaps_other_island?(islands, Island.t()) :: boolean
  defp overlaps_other_island?(islands, new_island) do
    Enum.any?(islands, fn {type, island} ->
      type != new_island.type and Island.overlaps?(island, new_island)
    end)
  end

  @spec check_islands(t, Coord.t()) :: {:hit, Island.t()} | {:miss, Coord.t()}
  defp check_islands(board, guess) do
    Enum.find_value(board.islands, {:miss, guess}, fn {_type, island} ->
      case Island.guess(island, guess) do
        {:hit, island} -> {:hit, island}
        :miss -> false
      end
    end)
  end

  @spec response({:hit, Island.t()} | {:miss, Coord.t()}, t) :: response
  defp response({:hit, island}, board) do
    board = put_in(board.islands[island.type], island)
    {:hit, forest_check(board, island), win_check(board), board}
  end

  defp response({:miss, guess}, board) do
    board = update_in(board.misses, &MapSet.put(&1, guess))
    {:miss, :none, :no_win, board}
  end

  @spec forest_check(t, Island.t()) :: Island.type() | :none
  defp forest_check(board, %Island{type: type} = _island) do
    if Island.forested?(board.islands[type]), do: type, else: :none
  end

  @spec win_check(t) :: :win | :no_win
  defp win_check(board), do: if(all_forested?(board), do: :win, else: :no_win)

  @spec all_forested?(t) :: boolean
  defp all_forested?(board) do
    Enum.all?(board.islands, fn {_type, island} -> Island.forested?(island) end)
  end
end
