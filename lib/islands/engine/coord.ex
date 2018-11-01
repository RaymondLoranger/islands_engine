defmodule Islands.Engine.Coord do
  use PersistConfig

  alias __MODULE__

  @enforce_keys [:row, :col]
  defstruct [:row, :col]

  @type col :: 1..10
  @type row :: 1..10
  @type t :: %Coord{row: row, col: col}

  @board_range Application.get_env(@app, :board_range)

  @spec new(row, col) :: {:ok, t} | {:error, atom}
  def new(row, col) when row in @board_range and col in @board_range do
    {:ok, %Coord{row: row, col: col}}
  end

  def new(_row, _col), do: {:error, :invalid_coordinate}
end
