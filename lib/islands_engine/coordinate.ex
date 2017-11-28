defmodule IslandsEngine.Coordinate do
  @moduledoc """
  Coordinate module...
  """

  use PersistConfig

  alias __MODULE__

  @enforce_keys [:row, :col]
  defstruct [:row, :col]

  @type col :: non_neg_integer
  @type row :: non_neg_integer
  @type t :: %Coordinate{col: col, row: row}

  @board_range Application.get_env(@app, :board_range)

  @spec new(row, col) :: {:ok, t} | {:error, atom}
  def new(row, col) when row in @board_range and col in @board_range do
    {:ok, %Coordinate{row: row, col: col}}
  end
  def new(_row, _col), do: {:error, :invalid_coordinate}
end