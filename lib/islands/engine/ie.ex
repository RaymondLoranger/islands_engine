defmodule Islands.Engine.IE do
  @moduledoc false

  # Functions for iex session...
  #
  # Examples:
  #   use Islands.Engine.IE
  #   print_coord_colors()
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

  alias Islands.Engine.Coord.Color

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      alias unquote(__MODULE__)
      alias IO.ANSI.Plus, as: ANSI
      alias Islands.Engine.Board.{Response, Server}
      alias Islands.Engine.Coord.Color

      alias Islands.Engine.Game.Server.{
        AddPlayer,
        Error,
        GuessCoord,
        Info,
        PositionAllIslands,
        PositionIsland,
        Restart,
        SetIslands,
        Stop
      }

      alias Islands.Engine.Game.Tally.Score

      alias Islands.Engine.Game.{
        Grid,
        Player,
        Server,
        State,
        Sup,
        Tally
      }

      alias Islands.Engine.Offsets

      alias Islands.Engine.{
        App,
        Board,
        Coord,
        DemoProc,
        Game,
        Guesses,
        IE,
        Island
      }

      alias Islands.Engine
      :ok
    end
  end

  def print_coord_colors() do
    IO.puts(":atoll       => #{Color.for(:atoll)}")
    IO.puts(":dot         => #{Color.for(:dot)}")
    IO.puts(":l_shape     => #{Color.for(:l_shape)}")
    IO.puts(":s_shape     => #{Color.for(:s_shape)}")
    IO.puts(":square      => #{Color.for(:square)}")

    IO.puts(":atoll_hit   => #{Color.for(:atoll_hit)}")
    IO.puts(":dot_hit     => #{Color.for(:dot_hit)}")
    IO.puts(":l_shape_hit => #{Color.for(:l_shape_hit)}")
    IO.puts(":s_shape_hit => #{Color.for(:s_shape_hit)}")
    IO.puts(":square_hit  => #{Color.for(:square_hit)}")

    IO.puts(":hit         => #{Color.for(:hit)}")
    IO.puts(":miss        => #{Color.for(:miss)}")
    IO.puts(":board_miss  => #{Color.for(:board_miss)}")
    IO.puts(":ocean       => #{Color.for(nil)}")
  end
end
