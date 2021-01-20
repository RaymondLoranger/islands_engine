defmodule Islands.Engine.IE do
  @moduledoc false

  ## Example of an IEx session in a named node...
  #
  #   iex --sname islands_engine -S mix  (Xterm colors)
  #
  #   use Islands.Engine.IE
  #   print_tiles()
  #   DemoProc.loop_test()
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

  ## Example of IEx sessions in different nodes...
  #
  #   iex --sname c1 -S mix (Xterm colors)
  #
  #   Islands.Text.Client.start("Eden", "Adam", :m, mode: :auto)
  #
  #   iex --sname c2 -S mix (Xterm colors)
  #
  #   Islands.Text.Client.join("Eden", "Eve", :f, mode: :auto)

  ## Example of an IEx session...
  #
  #   iex -S mix (Xterm colors)
  #
  #   use Islands.Engine.IE
  #   import Engine, only: [position_all_islands: 2]
  #   :observer.start
  #   pid = self()
  #   {:ok, red_sun_pid} = Engine.new_game("red-sun", "Ed", :m, pid)
  #   {:error, error} = Engine.new_game("red-sun", "Al", :m, pid)
  #   error = {:already_started, red_sun_pid}
  #   {:ok, icy_moon_pid} = Engine.new_game("icy-moon", "Eve", :f, pid)
  #   red_sun_pid = Engine.game_pid("red-sun")
  #   icy_moon_pid = Engine.game_pid("icy-moon")
  #   ["icy-moon", "red-sun"] = Engine.game_names
  #   game_names = :ets.match(Ets, {{GameServer, :"$1"}, :_})
  #   [["icy-moon"], ["red-sun"]] = game_names
  #   %Tally{} = Engine.add_player("red-sun", "Liz", :f, pid)
  #   :ok = position_all_islands("red-sun", :player1) |> Tally.summary(:player1)
  #   etc.

  use PersistConfig

  alias Islands.Grid.Tile
  alias Islands.{Coord, Engine, Game, Island, Player, PlayerID, Tally}

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      alias unquote(__MODULE__)
      alias IO.ANSI.Plus, as: ANSI
      alias Log.Reset

      alias Islands.Engine.GameServer.{
        AddPlayer,
        GuessCoord,
        PositionAllIslands,
        PositionIsland,
        ReplyTuple,
        SetIslands,
        Stop
      }

      alias Islands.Engine.{
        DemoProc,
        DynGameSup,
        Ets,
        GameRecovery,
        GameServer,
        GenServerProxy,
        Log,
        TopSup
      }

      alias Islands.Board.{Cache, Response}
      alias Islands.Grid.Tile
      alias Islands.Island.Offsets

      alias Islands.{
        Board,
        Coord,
        Engine,
        Game,
        Grid,
        Guesses,
        Island,
        Player,
        PlayerID,
        Request,
        Response,
        Score,
        State,
        Tally
      }

      :ok
    end
  end

  ## Example of an IEx session...
  #
  #   iex -S mix (Xterm colors)
  #
  #   use Islands.Engine.IE
  #   import Engine, only: [position_all_islands: 2]
  #   :observer.start # optional
  #   pid = self()
  #   new_games(2) # starts 2 new games with last called "blue-moon"
  #   Reset.reset_logs([:debug]) # optional
  #   :ets.match(Ets, {{GameServer, :"$1"}, :_})
  #   Engine.game_names
  #   %Tally{} = Engine.add_player(blue_moon, "Liz", :f, pid)
  #   :ok = position_all_islands(blue_moon, :player1) |> Tally.summary(:player1)
  #   :ok = position_island(blue_moon, <row>, <col>) # and then check the logs
  #   :ok = Engine.tally(blue_moon, :player1) |> Tally.summary(:player1)

  ## Example of an IEx session...
  #
  #   iex -S mix (Xterm colors)

  ## Example of an IEx session...
  #
  #   iex -S mix (Xterm colors)
  #
  #   use Islands.Engine.IE
  #   import Engine, only: [position_all_islands: 2]
  #   :observer.start # optional
  #   pid = self()
  #   new_games(166) # starts 166 new games with last called "blue-moon"
  #   Reset.reset_logs([:debug]) # optional
  #   :ets.match(Ets, {{GameServer, :"$1"}, :_})
  #   Engine.game_names
  #   %Tally{} = Engine.add_player(blue_moon, "Liz", :f, pid)
  #   :ok = position_all_islands(blue_moon, :player1) |> Tally.summary(:player1)
  #   :ok = position_island(DynGameSup, <row>, <col>) # and then check the logs
  #   :ok = Engine.tally(blue_moon, :player1) |> Tally.summary(:player1)

  ## Example of an IEx session...
  #
  #   iex -S mix (Xterm colors)
  #
  #   use Islands.Engine.IE
  #   import Engine, only: [position_all_islands: 2]
  #   :observer.start # optional
  #   pid = self()
  #   new_games(2) # starts 2 games with last called "blue-moon"
  #   Reset.reset_logs([:debug]) # optional
  #   %Tally{} = Engine.add_player(blue_moon, "Liz", :f, pid)
  #   :ok = position_all_islands(blue_moon, :player1) |> Tally.summary(:player1)
  #   pid = keep_killing(blue_moon)
  #   true = Process.exit(pid, :kill) # and then check the logs
  #   :ok = Engine.tally(blue_moon, :player1) |> Tally.summary(:player1)

  @spec print_tiles :: :ok
  def print_tiles do
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

    IO.puts(":board_miss  => #{Tile.new(:board_miss)}")
    IO.puts(":hit         => #{Tile.new(:hit)}")
    IO.puts(":miss        => #{Tile.new(:miss)}")
    IO.puts(":ocean       => #{Tile.new(nil)}")
  end

  @spec player_name :: Player.name()
  def player_name, do: "Ray"

  @spec gender :: Player.gender()
  def gender, do: :m

  @spec pid :: pid
  def pid, do: self()

  @spec player_id :: PlayerID.t()
  def player_id, do: :player1

  @spec island_type :: Island.type()
  def island_type, do: :atoll

  @spec blue_moon :: Game.name()
  def blue_moon, do: "blue-moon"

  @spec keep_killing(atom | binary) :: pid
  def keep_killing(name) when is_atom(name) or is_binary(name) do
    spawn(fn ->
      for _ <- Stream.cycle([:ok]) do
        pid(name)
        |> IO.inspect(label: "Killing #{inspect(name)}")
        |> Process.exit(:kill)

        pause(name)
        |> IO.inspect(label: "Between kills (ms)")
        |> Process.sleep()
      end
    end)
  end

  @spec new_games(pos_integer) :: [{Game.name(), Supervisor.on_start_child()}]
  def new_games(count) when count in 2..500 do
    Enum.reduce(0..(count - 2), [blue_moon()], fn _, acc ->
      [Game.haiku_name() | acc]
    end)
    |> Enum.map(fn name ->
      {name, Engine.new_game(name, player_name(), gender(), pid())}
    end)
  end

  @spec position_island(atom | binary, Coord.row(), Coord.col()) :: :ok
  def position_island(target, row, col)
      when (is_atom(target) or is_binary(target)) and row in 1..10 and
             col in 1..10 do
    keep_killing(target) |> do_position_island(row, col)
  end

  ## Private functions

  @spec do_position_island(pid, Coord.row(), Coord.col()) :: :ok
  defp do_position_island(killer_pid, row, col) do
    for _ <- 1..10 do
      Engine.position_island(blue_moon(), player_id(), island_type(), row, col)
      Process.sleep(10)
      Engine.game_pid(blue_moon())
    end
    |> Enum.any?(&is_nil/1)
    |> if(
      do: print_summary(killer_pid),
      else: do_position_island(killer_pid, row, col)
    )
  end

  @spec print_summary(pid) :: :ok
  defp print_summary(killer_pid) do
    true = Process.exit(killer_pid, :kill)
    :ok = Engine.tally(blue_moon(), player_id()) |> Tally.summary(player_id())
  end

  @spec pid(atom | binary) :: pid
  defp pid(name) when is_atom(name) do
    case Process.whereis(name) do
      pid when is_pid(pid) ->
        pid

      nil ->
        snooze() |> Process.sleep()
        pid(name)
    end
  end

  defp pid(name) when is_binary(name) do
    case Engine.game_pid(name) do
      pid when is_pid(pid) ->
        pid

      nil ->
        snooze() |> Process.sleep()
        pid(name)
    end
  end

  @spec pause(atom | binary) :: pos_integer
  defp pause(Islands.Engine.DynGameSup),
    do: get_env(:between_dyn_sup_kills)

  defp pause(Islands.Engine.GameSup),
    do: get_env(:between_sup_kills)

  defp pause(_), do: get_env(:between_server_kills)

  @spec snooze :: pos_integer
  defp snooze, do: get_env(:between_registration_checks)
end
