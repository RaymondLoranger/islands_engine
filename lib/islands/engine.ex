# ┌────────────────────────────────────────────────────────────────────┐
# │ Based on the book "Functional Web Development" by Lance Halvorsen. │
# └────────────────────────────────────────────────────────────────────┘
defmodule Islands.Engine do
  use GenServer.Proxy
  use PersistConfig

  @book_ref Application.get_env(@app, :book_ref)

  @moduledoc """
  Models the _Game of Islands_.
  \n##### #{@book_ref}
  """

  alias Islands.Engine.{DynSup, Server}
  alias Islands.{Coord, Island, Player, PlayerID, Tally}

  @coord_range 1..10
  @genders [:f, :m]
  @island_types [:atoll, :dot, :l_shape, :s_shape, :square]
  @player_ids [:player1, :player2]

  @doc """
  Starts a new game.
  """
  @spec new_game(String.t(), String.t(), Player.gender(), pid) ::
          Supervisor.on_start_child()
  def new_game(game_name, player1_name, gender, player1_pid)
      when is_binary(game_name) and is_binary(player1_name) and
             is_pid(player1_pid) and gender in @genders do
    DynamicSupervisor.start_child(
      DynSup,
      {Server, {game_name, player1_name, gender, player1_pid}}
    )
  end

  @doc """
  Ends a game.
  """
  @spec end_game(String.t()) :: :ok
  def end_game(game_name) when is_binary(game_name),
    do: stop(:shutdown, game_name)

  @doc """
  Stops a game.
  """
  @spec stop_game(String.t(), PlayerID.t()) :: Tally.t() | :ok
  def stop_game(game_name, player_id)
      when is_binary(game_name) and player_id in @player_ids,
      do: call({:stop, player_id}, game_name)

  @doc """
  Adds the second player of a game.
  """
  @spec add_player(String.t(), String.t(), Player.gender(), pid) ::
          Tally.t() | :ok
  def add_player(game_name, player2_name, gender, player2_pid)
      when is_binary(game_name) and is_binary(player2_name) and
             is_pid(player2_pid) and gender in @genders,
      do: call({:add_player, player2_name, gender, player2_pid}, game_name)

  @doc """
  Positions an island on the specified player's board.
  """
  @spec position_island(
          String.t(),
          PlayerID.t(),
          Island.type(),
          Coord.row(),
          Coord.col()
        ) :: Tally.t() | :ok
  def position_island(game_name, player_id, island_type, row, col)
      when is_binary(game_name) and player_id in @player_ids and
             island_type in @island_types and row in @coord_range and
             col in @coord_range,
      do: call({:position_island, player_id, island_type, row, col}, game_name)

  @doc """
  Positions all islands on the specified player's board.
  """
  @spec position_all_islands(String.t(), PlayerID.t()) :: Tally.t() | :ok
  def position_all_islands(game_name, player_id)
      when is_binary(game_name) and player_id in @player_ids,
      do: call({:position_all_islands, player_id}, game_name)

  @doc """
  Declares all islands set for the specified player.
  """
  @spec set_islands(String.t(), PlayerID.t()) :: Tally.t() | :ok
  def set_islands(game_name, player_id)
      when is_binary(game_name) and player_id in @player_ids,
      do: call({:set_islands, player_id}, game_name)

  @doc """
  Allows the specified player to guess a coordinate.
  """
  @spec guess_coord(String.t(), PlayerID.t(), Coord.row(), Coord.col()) ::
          Tally.t() | :ok
  def guess_coord(game_name, player_id, row, col)
      when is_binary(game_name) and player_id in @player_ids and
             row in @coord_range and col in @coord_range,
      do: call({:guess_coord, player_id, row, col}, game_name)

  @doc """
  Returns the tally of the game for the specified player.
  """
  @spec tally(String.t(), PlayerID.t()) :: Tally.t() | :ok
  def tally(game_name, player_id)
      when is_binary(game_name) and player_id in @player_ids,
      do: call({:tally, player_id}, game_name)

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
  given `game_name`, or `nil` if no such process is registered.
  """
  @spec game_pid(String.t()) :: pid | nil
  def game_pid(game_name), do: game_name |> Server.via() |> GenServer.whereis()
end
