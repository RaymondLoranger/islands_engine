defmodule IslandsEngine.Guesses do
  @moduledoc """
  Guesses module...
  """

  alias IslandsEngine.{Coordinate, Guesses}

  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  @type hits :: MapSet.t(Coordinate.t)
  @type misses :: MapSet.t(Coordinate.t)
  @type t :: %Guesses{hits: hits, misses: misses}

  @spec new() :: t
  def new(), do: %Guesses{hits: MapSet.new(), misses: MapSet.new()}

  @spec add(t, atom, Coordinate.t) :: t
  def add(%Guesses{} = guesses, :hit, %Coordinate{} = coordinate) do
    update_in(guesses.hits, &MapSet.put(&1, coordinate))
  end
  def add(%Guesses{} = guesses, :miss, %Coordinate{} = coordinate) do
    update_in(guesses.misses, &MapSet.put(&1, coordinate))
  end
end