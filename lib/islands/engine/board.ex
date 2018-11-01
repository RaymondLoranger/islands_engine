defmodule Islands.Engine.Board do
  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.Board.Response
  alias Islands.Engine.{Coord, Island}

  @enforce_keys [:islands, :misses]
  defstruct [:islands, :misses]

  @type islands :: %{Island.type() => Island.t()}
  @type t :: %Board{islands: islands, misses: Island.coords()}

  @island_types Application.get_env(@app, :island_types)

  @spec new() :: t
  def new(), do: %Board{islands: %{}, misses: MapSet.new()}

  @spec position_island(t, Island.t()) :: t | {:error, atom}
  def position_island(%Board{} = board, %Island{} = island) do
    if overlaps_board_island?(board.islands, island),
      do: {:error, :overlapping_island},
      else: put_in(board.islands[island.type], island)
  end

  @spec all_islands_positioned?(t) :: boolean
  def all_islands_positioned?(%Board{} = board) do
    Enum.all?(@island_types, &Map.has_key?(board.islands, &1))
  end

  @spec guess(t, Coord.t()) :: Response.t()
  def guess(%Board{} = board, %Coord{} = guess) do
    guess |> Response.check_guess(board) |> Response.format_response(board)
  end

  ## Private functions

  @spec overlaps_board_island?(Board.islands(), Island.t()) :: boolean
  defp overlaps_board_island?(islands, new_island) do
    Enum.any?(islands, fn {type, island} ->
      type != new_island.type and Island.overlaps?(island, new_island)
    end)
  end
end
