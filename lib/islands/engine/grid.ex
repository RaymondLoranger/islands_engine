defmodule Islands.Engine.Grid do
  @moduledoc """
  Converts a player's board/guesses to a grid (map of maps).
  Also converts a grid to a list of maps.
  """

  use PersistConfig

  alias IO.ANSI.Plus, as: ANSI
  alias Islands.Engine.{Board, Coord, Format, Guesses, Island}

  @type t :: %{Coord.row() => %{Coord.col() => atom}}

  @board_range Application.get_env(@app, :board_range)

  @doc """
  Returns an "empty" grid.

  ## Examples

      iex> alias Islands.Engine.Grid
      iex> %{1 => row_1} = Grid.new()
      iex> row_1
      %{
        1 => nil, 2 => nil, 3 => nil, 4 => nil, 5  => nil,
        6 => nil, 7 => nil, 8 => nil, 9 => nil, 10 => nil
      }
  """
  @spec new() :: t
  def new() do
    for row <- @board_range, into: %{} do
      {row, for(col <- @board_range, into: %{}, do: {col, nil})}
    end
  end

  @doc """
  Converts a board map or a guesses struct to a grid.

  ## Examples

      # iex> {:ok, atoll_coord} = Coord.new(1, 1)
      # iex> {:ok, atoll_hit} = Coord.new(1, 2)
      # iex> {:ok, atoll} = Island.new(:atoll, atoll_coord)
      # iex>
      # iex> {:hit, :none, :no_win, board} =
      # iex>   Board.new()
      # iex>   |> Board.position_island(atoll)
      # iex>   |> Board.guess(atoll_hit)
      # iex>
      # iex> %{1 => row_1} = Grid.new(board)
      # iex> row_1
      # %{
      #   1 => :atoll, 2 => :atoll_hit, 3 => nil, 4 => nil, 5  => nil,
      #   6 => nil   , 7 => nil       , 8 => nil, 9 => nil, 10 => nil
      # }

      # iex> {:ok, atoll_coord} = Coord.new(1, 1)
      # iex> {:ok, atoll_hit} = Coord.new(1, 2)
      # iex>
      # iex> guesses =
      # iex>   Guesses.new()
      # iex>   |> Guesses.add(:miss, atoll_coord)
      # iex>   |> Guesses.add(:hit, atoll_hit)
      # iex>
      # iex> %{1 => row_1} = Grid.new(guesses)
      # iex> row_1
      # %{
      #   1 => :miss, 2 => :hit, 3 => nil, 4 => nil, 5  => nil,
      #   6 => nil  , 7 => nil , 8 => nil, 9 => nil, 10 => nil
      # }
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

  ## Examples

      # iex> {:ok, atoll_coord} = Coord.new(1, 1)
      # iex> {:ok, atoll_hit} = Coord.new(1, 2)
      # iex> {:ok, atoll} = Island.new(:atoll, atoll_coord)
      # iex>
      # iex> {:hit, :none, :no_win, board} =
      # iex>   Board.new()
      # iex>   |> Board.position_island(atoll)
      # iex>   |> Board.guess(atoll_hit)
      # iex>
      # iex> [row_1 | _other_rows] = board |> Grid.new() |> Grid.to_maps(& &1)
      # iex> row_1
      # %{"row" => 1,
      #   1 => :atoll, 2 => :atoll_hit, 3 => nil, 4 => nil, 5  => nil,
      #   6 => nil   , 7 => nil       , 8 => nil, 9 => nil, 10 => nil
      # }
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
