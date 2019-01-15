defmodule Islands.Engine.IE do
  @moduledoc false

  # Example of an IEx session...
  #
  #   iex --sname islands -S mix
  #
  #   use Islands.Engine.IE
  #   print_tiles()
  #   DemoProc.loop_test()

  # Example of an IEx session...
  #
  #   iex --sname islands -S mix
  #
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
  alias Islands.Engine

  # Supervisor option defaults for :max_restarts and :max_seconds
  @max_restarts 3
  @max_seconds 5
  @seconds_per_restart Float.round(@max_seconds / @max_restarts, 0)
  @pause round(@seconds_per_restart * 1000)
  @snooze 10

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      alias unquote(__MODULE__)
      alias IO.ANSI.Plus, as: ANSI
      alias Islands.Engine.Board.{Response, Score, Server}
      alias Islands.Engine.Game.Grid.Tile

      alias Islands.Engine.Game.Server.{
        AddPlayer,
        Error,
        GuessCoord,
        PositionAllIslands,
        PositionIsland,
        Restart,
        SetIslands,
        Stop
      }

      alias Islands.Engine.Game.{
        DynSup,
        Grid,
        Player,
        Server,
        State,
        Tally
      }

      alias Islands.Engine.Island.Offsets

      alias Islands.Engine.{
        App,
        Board,
        Callback,
        Coord,
        DemoProc,
        Game,
        Guesses,
        Island,
        Log,
        Sup
      }

      alias Islands.Engine
      :ok
    end
  end

  @spec print_tiles() :: :ok
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

  # iex --sname c1 -S mix
  #
  # Islands.Text.Client.start("Eden", "Adam", mode: :auto)

  # iex --sname c2 -S mix
  #
  # Islands.Text.Client.join("Eden", "Eve", mode: :auto)

  # iex --sname islands -S mix
  #
  # :observer.start # optional
  # use Islands.Engine.IE
  # pid = keep_killing(Sup)
  # pid = keep_killing(DynSup)
  # pid = keep_killing("Eden")
  # Process.exit(pid, :kill)
  @spec keep_killing(atom | binary) :: pid
  def keep_killing(name) do
    spawn(fn ->
      for _ <- Stream.cycle([:ok]) do
        name |> pid() |> Process.exit(:kill)
        Process.sleep(@pause)
      end
    end)
  end

  ## Private functions

  @spec pid(atom | binary) :: pid
  defp pid(name) when is_atom(name) do
    case Process.whereis(name) do
      pid when is_pid(pid) ->
        pid

      nil ->
        Process.sleep(@snooze)
        pid(name)
    end
  end

  defp pid(name) when is_binary(name) do
    case Engine.game_pid(name) do
      pid when is_pid(pid) ->
        pid

      nil ->
        Process.sleep(@snooze)
        pid(name)
    end
  end
end
