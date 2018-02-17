defmodule Islands.Engine.Guesses do
  # @moduledoc """
  # Guesses module...
  # """
  @moduledoc false

  alias __MODULE__
  alias Islands.Engine.Coord

  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  @type hits :: MapSet.t(Coord.t())
  @type misses :: MapSet.t(Coord.t())
  @type t :: %Guesses{hits: hits, misses: misses}

  @spec new() :: t
  def new(), do: %Guesses{hits: MapSet.new(), misses: MapSet.new()}

  @spec add(t, atom, Coord.t()) :: t
  def add(%Guesses{} = guesses, :hit, %Coord{} = coord) do
    update_in(guesses.hits, &MapSet.put(&1, coord))
  end

  def add(%Guesses{} = guesses, :miss, %Coord{} = coord) do
    update_in(guesses.misses, &MapSet.put(&1, coord))
  end
end
