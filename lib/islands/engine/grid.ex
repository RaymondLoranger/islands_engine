defmodule Islands.Engine.Grid do
  # @moduledoc """
  # Converts a player's board/guesses to a grid (map of maps).
  # Also converts a grid to a list of maps.
  # """
  @moduledoc false

  use PersistConfig

  alias IO.ANSI.Plus, as: ANSI
  alias Islands.Engine.{Board, Coord, Format, Guesses, Island}

  @type t :: %{Coord.row() => %{Coord.col() => atom}}

  @board_range Application.get_env(@app, :board_range)

  @doc """
  Returns an "empty" grid.
  """
  @spec new() :: t
  def new() do
    for row <- @board_range, into: %{} do
      {row, for(col <- @board_range, into: %{}, do: {col, nil})}
    end
  end

  @doc """
  Converts a board map or a guesses struct to a grid.
  """
  @spec new(Board.t() | Guesses.t()) :: t
  def new(board_or_guesses)

  def new(%Board{islands: islands, misses: misses}) do
    islands
    |> Map.values()
    |> Enum.reduce(new(), fn island, grid ->
      %Island{type: type, coords: coords, hits: hits} = island

      grid
      |> update(coords, type)
      |> update(hits, :"#{type}_hit")
      |> update(misses, :board_miss)
    end)
  end

  def new(%Guesses{hits: hits, misses: misses}) do
    new() |> update(hits, :hit) |> update(misses, :miss)
  end

  @doc """
  Converts a grid to a list of maps.
  """
  @spec to_maps(t, (atom -> ANSI.ansidata())) :: [map]
  def to_maps(grid, fun \\ &Format.for/1) when is_function(fun, 1) do
    for {row_num, row_map} <- grid do
      [
        {"row", row_num}
        | for {col_num, cell_val} <- row_map do
            {col_num, fun.(cell_val)}
          end
      ]
      |> Map.new()
    end
  end

  ## Private functions

  @spec update(t, Island.coords(), atom) :: t
  defp update(grid, coords, value) do
    coords
    |> MapSet.to_list()
    |> Enum.reduce(grid, fn %Coord{row: row, col: col}, grid ->
      put_in(grid, [row, col], value)
    end)
  end
end
