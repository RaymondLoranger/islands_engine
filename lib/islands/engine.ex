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

  import Islands.Engine.Guards

  alias Islands.Engine.{DynSup, Server}
  alias Islands.{Coord, Island, Player, PlayerID, Tally}

  @doc """
  Starts a new game.
  """
  @spec new_game(String.t(), String.t(), Player.gender(), pid) ::
          Supervisor.on_start_child()
  def new_game(game_name, player1_name, gender, pid)
      when valid?(game_name, player1_name, gender, pid) do
    child_spec = {Server, {game_name, player1_name, gender, pid}}
    DynamicSupervisor.start_child(DynSup, child_spec)
  end

  @doc """
  Ends a game.
  """
  @spec end_game(String.t()) :: :ok | {:error, term}
  def end_game(game_name) when is_binary(game_name),
    do: stop(:shutdown, game_name)

  @doc """
  Stops a game.
  """
  @spec stop_game(String.t(), PlayerID.t()) :: Tally.t() | {:error, term}
  def stop_game(game_name, player_id) when valid?(game_name, player_id),
    do: call({:stop, player_id}, game_name)

  @doc """
  Adds the second player of a game.
  """
  @spec add_player(String.t(), String.t(), Player.gender(), pid) ::
          Tally.t() | {:error, term}
  def add_player(game_name, player2_name, gender, pid)
      when valid?(game_name, player2_name, gender, pid),
      do: call({:add_player, player2_name, gender, pid}, game_name)

  @doc """
  Positions an island on the specified player's board.
  """
  @spec position_island(
          String.t(),
          PlayerID.t(),
          Island.type(),
          Coord.row(),
          Coord.col()
        ) :: Tally.t() | {:error, term}
  def position_island(game_name, player_id, island_type, row, col)
      when valid?(game_name, player_id, island_type, row, col),
      do: call({:position_island, player_id, island_type, row, col}, game_name)

  @doc """
  Positions all islands on the specified player's board.
  """
  @spec position_all_islands(String.t(), PlayerID.t()) ::
          Tally.t() | {:error, term}
  def position_all_islands(game_name, player_id)
      when valid?(game_name, player_id),
      do: call({:position_all_islands, player_id}, game_name)

  @doc """
  Declares all islands set for the specified player.
  """
  @spec set_islands(String.t(), PlayerID.t()) :: Tally.t() | {:error, term}
  def set_islands(game_name, player_id) when valid?(game_name, player_id),
    do: call({:set_islands, player_id}, game_name)

  @doc """
  Allows the specified player to guess a coordinate.
  """
  @spec guess_coord(String.t(), PlayerID.t(), Coord.row(), Coord.col()) ::
          Tally.t() | {:error, term}
  def guess_coord(game_name, player_id, row, col)
      when correct?(game_name, player_id, row, col),
      do: call({:guess_coord, player_id, row, col}, game_name)

  @doc """
  Returns the tally of the game for the specified player.
  """
  @spec tally(String.t(), PlayerID.t()) :: Tally.t() | {:error, term}
  def tally(game_name, player_id) when valid?(game_name, player_id),
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
