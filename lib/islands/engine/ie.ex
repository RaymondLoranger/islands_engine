defmodule Islands.Engine.IE do
  @moduledoc false

  # Functions for iex session...
  #
  # Examples:
  #   use Islands.Engine.IE
  #   print_tile_colors()
  #   DemoProc.loop_test()

  #   use Islands.Engine.IE
  #   guesses = Guesses.new()
  #   {:ok, coord1} = Coord.new(1, 1)
  #   {:ok, coord2} = Coord.new(2, 2)
  #   guesses = update_in(guesses.hits, &MapSet.put(&1, coord1))
  #   guesses = update_in(guesses.hits, &MapSet.put(&1, coord2))
  #   guesses = update_in(guesses.hits, &MapSet.put(&1, coord1))
  #   {:ok, coord} = Coord.new(4, 6)
  #   Island.new(:l_shape, coord)
  #   Island.new(:wrong, coord)
  #   {:ok, coord} = Coord.new(10, 10)
  #   Island.new(:l_shape, coord)
  #   Island.new(:dot, coord)

  alias Islands.Engine.Format

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      alias unquote(__MODULE__)
      alias Islands.Engine

      alias Islands.Engine.{
        App,
        Board,
        Coord,
        DemoProc,
        Error,
        Format,
        Game,
        Grid,
        Guesses,
        Island,
        Offsets,
        Player,
        Recover,
        Server,
        State,
        Sup,
        Tally,
        Player
      }

      :ok
    end
  end

  def print_tile_colors() do
    IO.puts(":atoll       => #{Format.for(:atoll)}")
    IO.puts(":dot         => #{Format.for(:dot)}")
    IO.puts(":l_shape     => #{Format.for(:l_shape)}")
    IO.puts(":s_shape     => #{Format.for(:s_shape)}")
    IO.puts(":square      => #{Format.for(:square)}")

    IO.puts(":atoll_hit   => #{Format.for(:atoll_hit)}")
    IO.puts(":dot_hit     => #{Format.for(:dot_hit)}")
    IO.puts(":l_shape_hit => #{Format.for(:l_shape_hit)}")
    IO.puts(":s_shape_hit => #{Format.for(:s_shape_hit)}")
    IO.puts(":square_hit  => #{Format.for(:square_hit)}")

    IO.puts(":hit         => #{Format.for(:hit)}")
    IO.puts(":miss        => #{Format.for(:miss)}")
    IO.puts(":board_miss  => #{Format.for(:board_miss)}")
    IO.puts(":ocean       => #{Format.for(nil)}")
  end
end
