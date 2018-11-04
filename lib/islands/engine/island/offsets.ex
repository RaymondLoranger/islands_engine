defmodule Islands.Engine.Island.Offsets do
  @moduledoc """
  Returns a list of offsets for each island type.
  """

  alias Islands.Engine.Island

  @type t :: [{0..2, 0..2}]

  @doc """
  Returns a list of offsets for a given island type.
  """
  @spec offsets_for(Island.type()) :: t | {:error, atom}
  def offsets_for(:atoll), do: [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}]
  def offsets_for(:dot), do: [{0, 0}]
  def offsets_for(:l_shape), do: [{0, 0}, {1, 0}, {2, 0}, {2, 1}]
  def offsets_for(:s_shape), do: [{0, 1}, {0, 2}, {1, 0}, {1, 1}]
  def offsets_for(:square), do: [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  def offsets_for(_unknown), do: {:error, :invalid_island_type}
end
