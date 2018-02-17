defmodule Islands.Engine.Island do
  # @moduledoc """
  # Island module...
  # """
  @moduledoc false

  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.Coord

  @enforce_keys [:type, :coords, :hits]
  defstruct [:type, :coords, :hits]

  @type coords :: MapSet.t(Coord.t())
  @type hits :: MapSet.t(Coord.t())
  @type t :: %Island{type: type, coords: coords, hits: hits}
  @type type :: :atoll | :dot | :l_shape | :s_shape | :square

  @offsets Application.get_env(@app, :island_type_offsets)
  @types Application.get_env(@app, :island_types)

  @dialyzer {:no_opaque, new: 2}
  @spec new(type, Coord.t()) :: {:ok, t} | {:error, atom}
  def new(type, %Coord{} = origin) when type in @types do
    with %MapSet{} = coords <- coords(@offsets[type], origin),
         do: {:ok, %Island{type: type, coords: coords, hits: MapSet.new()}},
         else: ({:error, reason} -> {:error, reason})
  end

  def new(_type, %Coord{}), do: {:error, :invalid_island_type}
  def new(_type, _origin), do: {:error, :improper_origin}

  @spec overlaps?(t, t) :: boolean
  def overlaps?(%Island{} = other_island, %Island{} = island) do
    not MapSet.disjoint?(other_island.coords, island.coords)
  end

  @spec guess(t, Coord.t()) :: {:hit, t} | :miss
  def guess(%Island{} = island, %Coord{} = guess) do
    if MapSet.member?(island.coords, guess),
      do: {:hit, update_in(island.hits, &MapSet.put(&1, guess))},
      else: :miss
  end

  @spec forested?(t) :: boolean
  def forested?(%Island{} = island) do
    MapSet.equal?(island.coords, island.hits)
  end

  ## Private functions

  @spec coords([tuple], Coord.t()) :: coords | {:error, atom}
  defp coords(offsets, _origin = %Coord{row: row, col: col}) do
    Enum.reduce_while(offsets, %MapSet{}, fn {row_offset, col_offset}, set ->
      case Coord.new(row + row_offset, col + col_offset) do
        {:ok, coord} -> {:cont, MapSet.put(set, coord)}
        {:error, _reason} -> {:halt, {:error, :invalid_origin}}
      end
    end)
  end
end
