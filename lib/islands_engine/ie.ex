defmodule IslandsEngine.IE do
  @moduledoc false

  # Functions for iex session...
  #
  # Examples:
  #   use IslandsEngine.IE
  #   guesses = Guesses.new()
  #   {:ok, coordinate1} = Coordinate.new(1, 1)
  #   {:ok, coordinate2} = Coordinate.new(2, 2)
  #   guesses = update_in(guesses.hits, &MapSet.put(&1, coordinate1))
  #   guesses = update_in(guesses.hits, &MapSet.put(&1, coordinate2))
  #   guesses = update_in(guesses.hits, &MapSet.put(&1, coordinate1))
  #   {:ok, coordinate} = Coordinate.new(4, 6)
  #   Island.new(:l_shape, coordinate)
  #   Island.new(:wrong, coordinate)
  #   {:ok, coordinate} = Coordinate.new(10, 10)
  #   Island.new(:l_shape, coordinate)

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      alias unquote(__MODULE__)
      alias IslandsEngine.{Board, Coordinate, Guesses, Island}
      :ok
    end
  end
end
