defmodule Islands.Engine.Coord do
  @moduledoc false

  use PersistConfig

  alias __MODULE__

  @enforce_keys [:row, :col]
  defstruct [:row, :col]

  @type col :: pos_integer
  @type row :: pos_integer
  @type t :: %Coord{row: row, col: col}

  @board_range Application.get_env(@app, :board_range)

  @spec new(row, col) :: {:ok, t} | {:error, atom}
  def new(row, col) when row in @board_range and col in @board_range do
    {:ok, %Coord{row: row, col: col}}
  end

  def new(_row, _col), do: {:error, :invalid_coordinate}
end
