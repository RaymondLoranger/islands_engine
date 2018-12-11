# ┌────────────────────────────────────────────────────────────────────┐
# │ Based on the book "Functional Web Development" by Lance Halvorsen. │
# └────────────────────────────────────────────────────────────────────┘
defmodule Islands.Engine do
  use PersistConfig

  @book_ref Application.get_env(@app, :book_ref)

  @moduledoc """
  Models the _Game of Islands_.
  \n##### #{@book_ref}
  """

  alias Islands.Engine.Game.{DynSup, Server, Tally}
  alias Islands.Engine.{Coord, Game, Island, Proxy}

  @board_range Application.get_env(@app, :board_range)
  @island_types Application.get_env(@app, :island_types)
  @player_ids Application.get_env(@app, :player_ids)

  @doc """
  Starts a new game.
  """
  @spec new_game(String.t(), String.t(), pid) :: Supervisor.on_start_child()
  def new_game(game_name, player1_name, player1_pid)
      when is_binary(game_name) and is_binary(player1_name) and
             is_pid(player1_pid) do
    import DynamicSupervisor, only: [start_child: 2]
    start_child(DynSup, {Server, {game_name, player1_name, player1_pid}})
  end

  @doc """
  Ends a game.
  """
  @spec end_game(String.t()) :: :ok
  def end_game(game_name) when is_binary(game_name),
    do: Proxy.stop(:shutdown, game_name, __ENV__.function)

  @doc """
  Stops a game.
  """
  @spec stop_game(String.t(), Game.player_id()) :: Tally.t()
  def stop_game(game_name, player_id)
      when is_binary(game_name) and player_id in @player_ids,
      do: Proxy.call({:stop, player_id}, game_name, __ENV__.function)

  @doc """
  Adds the second player of a game.
  """
  @spec add_player(String.t(), String.t(), pid) :: Tally.t()
  def add_player(game_name, player2_name, player2_pid)
      when is_binary(game_name) and is_binary(player2_name) and
             is_pid(player2_pid) do
    {:add_player, player2_name, player2_pid}
    |> Proxy.call(game_name, __ENV__.function)
  end

  @doc """
  Positions an island on a player's board.
  """
  @spec position_island(
          String.t(),
          Game.player_id(),
          Island.type(),
          Coord.row(),
          Coord.col()
        ) :: Tally.t()
  def position_island(game_name, player_id, island_type, row, col)
      when is_binary(game_name) and player_id in @player_ids and
             island_type in @island_types and row in @board_range and
             col in @board_range do
    {:position_island, player_id, island_type, row, col}
    |> Proxy.call(game_name, __ENV__.function)
  end

  @doc """
  Positions all islands on a player's board.
  """
  @spec position_all_islands(String.t(), Game.player_id()) :: Tally.t()
  def position_all_islands(game_name, player_id)
      when is_binary(game_name) and player_id in @player_ids do
    {:position_all_islands, player_id}
    |> Proxy.call(game_name, __ENV__.function)
  end

  @doc """
  Declares all islands set for a player.
  """
  @spec set_islands(String.t(), Game.player_id()) :: Tally.t()
  def set_islands(game_name, player_id)
      when is_binary(game_name) and player_id in @player_ids,
      do: Proxy.call({:set_islands, player_id}, game_name, __ENV__.function)

  @doc """
  Allows a player to guess a coordinate.
  """
  @spec guess_coord(String.t(), Game.player_id(), Coord.row(), Coord.col()) ::
          Tally.t()
  def guess_coord(game_name, player_id, row, col)
      when is_binary(game_name) and player_id in @player_ids and
             row in @board_range and col in @board_range do
    {:guess_coord, player_id, row, col}
    |> Proxy.call(game_name, __ENV__.function)
  end

  @doc """
  Returns the tally of a game for a given player.
  """
  @spec tally(String.t(), Game.player_id()) :: Tally.t()
  def tally(game_name, player_id)
      when is_binary(game_name) and player_id in @player_ids,
      do: Proxy.call({:tally, player_id}, game_name, __ENV__.function)

  @doc """
  Returns a sorted list of registered game names.
  """
  @spec game_names :: [String.t()]
  def game_names do
    :global.registered_names()
    |> Enum.filter(&(is_tuple(&1) and elem(&1, 0) == Server))
    |> Enum.map(&elem(&1, 1))
  end

  @doc """
  Returns the `pid` of the game server process registered under the
  given `game_name`, or `nil` if no process is registered.
  """
  @spec game_pid(String.t()) :: pid | nil
  def game_pid(game_name), do: game_name |> Server.via() |> GenServer.whereis()
end
