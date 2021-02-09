# ┌────────────────────────────────────────────────────────────────────┐
# │ Based on the book "Functional Web Development" by Lance Halvorsen. │
# └────────────────────────────────────────────────────────────────────┘
defmodule Islands.Engine do
  @moduledoc """
  Models the _Game of Islands_.

  ##### Based on the book [Functional Web Development](https://pragprog.com/book/lhelph/functional-web-development-with-elixir-otp-and-phoenix) by Lance Halvorsen.
  """

  use GenServer.Proxy

  import Islands.Engine.Guards

  alias Islands.Engine.{DynGameSup, GameServer}
  alias Islands.{Coord, Game, Island, Player, PlayerID, Tally}

  @doc """
  Starts a new game server process and supervises it.
  """
  @spec new_game(Game.name(), Player.name(), Player.gender(), pid) ::
          Supervisor.on_start_child()
  def new_game(game_name, player1_name, gender, pid)
      when valid?(game_name, player1_name, gender, pid) do
    child_spec = {GameServer, {game_name, player1_name, gender, pid}}
    DynamicSupervisor.start_child(DynGameSup, child_spec)
  end

  @doc """
  Stops a game server process normally. It won't be restarted.
  """
  @spec end_game(Game.name()) :: :ok | {:error, term}
  def end_game(game_name) when is_binary(game_name),
    do: stop(:shutdown, game_name)

  @doc """
  Stops a game at a player's request.
  """
  @spec stop_game(Game.name(), PlayerID.t()) :: Tally.t() | {:error, term}
  def stop_game(game_name, player_id) when valid?(game_name, player_id),
    do: call({:stop, player_id}, game_name)

  @doc """
  Adds the second player of a game.
  """
  @spec add_player(Game.name(), Player.name(), Player.gender(), pid) ::
          Tally.t() | {:error, term}
  def add_player(game_name, player2_name, gender, pid)
      when valid?(game_name, player2_name, gender, pid),
      do: call({:add_player, player2_name, gender, pid}, game_name)

  @doc """
  Positions an island on the specified player's board.
  """
  @spec position_island(
          Game.name(),
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
  @spec position_all_islands(Game.name(), PlayerID.t()) ::
          Tally.t() | {:error, term}
  def position_all_islands(game_name, player_id)
      when valid?(game_name, player_id),
      do: call({:position_all_islands, player_id}, game_name)

  @doc """
  Declares all islands set for the specified player.
  """
  @spec set_islands(Game.name(), PlayerID.t()) :: Tally.t() | {:error, term}
  def set_islands(game_name, player_id) when valid?(game_name, player_id),
    do: call({:set_islands, player_id}, game_name)

  @doc """
  Lets the specified player guess square (`row`, `col`).
  """
  @spec guess_coord(Game.name(), PlayerID.t(), Coord.row(), Coord.col()) ::
          Tally.t() | {:error, term}
  def guess_coord(game_name, player_id, row, col)
      when valid_args?(game_name, player_id, row, col),
      do: call({:guess_coord, player_id, row, col}, game_name)

  @doc """
  Returns the tally of a game for the specified player.
  """
  @spec tally(Game.name(), PlayerID.t()) :: Tally.t() | {:error, term}
  def tally(game_name, player_id) when valid?(game_name, player_id),
    do: call({:tally, player_id}, game_name)

  @doc """
  Returns an overview of all the games being played.
  """
  @spec games_overview :: [Game.overview()]
  def games_overview do
    GenServer.call(GameRecovery, :games_overview)
  end

  @doc """
  Returns a sorted list of registered game names.
  """
  @spec game_names :: [Game.name()]
  def game_names do
    :global.registered_names()
    |> Enum.map(&game_name/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.sort()
  end

  @doc """
  Returns the `pid` of the game server process registered via the
  given `game_name`, or `nil` if no such process is registered.
  """
  @spec game_pid(Game.name()) :: pid | nil
  def game_pid(game_name),
    do: GameServer.via(game_name) |> GenServer.whereis()

  ## Private functions

  @spec game_name(term) :: Game.name() | atom
  defp game_name({GameServer, game_name}), do: game_name
  defp game_name(_), do: nil
end
