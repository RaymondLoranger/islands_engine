defmodule Islands.Engine.IE do
  @moduledoc false

  # Functions for iex session...
  #
  # Examples:
  #   use Islands.Engine.IE
  #   print_tiles()
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

  alias Islands.Engine.Game.Grid.Tile

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      alias unquote(__MODULE__)
      alias IO.ANSI.Plus, as: ANSI
      alias Islands.Engine.Board.{Response, Server}
      alias Islands.Engine.Game.Grid.Tile

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
        DynSup,
        Grid,
        Player,
        Server,
        State,
        Tally
      }

      alias Islands.Engine.Islands.Offsets

      alias Islands.Engine.{
        App,
        Board,
        Coord,
        DemoProc,
        Game,
        Guesses,
        IE,
        Island,
        Sup
      }

      alias Islands.Engine
      :ok
    end
  end

  def print_tiles() do
    IO.puts(":atoll       => #{Tile.new(:atoll)}")
    IO.puts(":dot         => #{Tile.new(:dot)}")
    IO.puts(":l_shape     => #{Tile.new(:l_shape)}")
    IO.puts(":s_shape     => #{Tile.new(:s_shape)}")
    IO.puts(":square      => #{Tile.new(:square)}")

    IO.puts(":atoll_hit   => #{Tile.new(:atoll_hit)}")
    IO.puts(":dot_hit     => #{Tile.new(:dot_hit)}")
    IO.puts(":l_shape_hit => #{Tile.new(:l_shape_hit)}")
    IO.puts(":s_shape_hit => #{Tile.new(:s_shape_hit)}")
    IO.puts(":square_hit  => #{Tile.new(:square_hit)}")

    IO.puts(":hit         => #{Tile.new(:hit)}")
    IO.puts(":miss        => #{Tile.new(:miss)}")
    IO.puts(":board_miss  => #{Tile.new(:board_miss)}")
    IO.puts(":ocean       => #{Tile.new(nil)}")
  end
end
