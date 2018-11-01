defmodule Islands.Engine.Island.Offsets do
  @moduledoc """
  Returns a list of offsets for each island type.
  """

  alias Islands.Engine.Island

  @type t :: [{0..2, 0..2}]

  @doc """
  Returns a list of offsets for a given island type.
  """
  @spec for(Island.type()) :: t | {:error, atom}
  def for(:atoll), do: [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}]
  def for(:dot), do: [{0, 0}]
  def for(:l_shape), do: [{0, 0}, {1, 0}, {2, 0}, {2, 1}]
  def for(:s_shape), do: [{0, 1}, {0, 2}, {1, 0}, {1, 1}]
  def for(:square), do: [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  def for(_unknown), do: {:error, :invalid_island_type}
end
