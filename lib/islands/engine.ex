# ┌────────────────────────────────────────────────────────────────────┐
# │ Based on the book "Functional Web Development" by Lance Halvorsen. │
# └────────────────────────────────────────────────────────────────────┘
defmodule Islands.Engine do
  use PersistConfig

  @book_ref Application.get_env(@app, :book_ref)

  @moduledoc """
  Models the Game of Islands.
  \n##### #{@book_ref}
  """

  alias Islands.Engine.Game.{Server, Sup, Tally}
  alias Islands.Engine.{Coord, Game, Island}

  @board_range Application.get_env(@app, :board_range)
  @island_types Application.get_env(@app, :island_types)
  @player_ids Application.get_env(@app, :player_ids)

  @doc """
  Starts a new game.
  """
  @spec new_game(String.t(), pid) :: Supervisor.on_start_child()
  def new_game(player1_name, player1_pid)
      when is_binary(player1_name) and is_pid(player1_pid) do
    DynamicSupervisor.start_child(Sup, {Server, {player1_name, player1_pid}})
  end

  @doc """
  Ends a game.
  """
  @spec end_game(String.t()) :: :ok
  def end_game(player1_name) when is_binary(player1_name) do
    player1_name |> Server.via() |> GenServer.stop(:shutdown)
  end

  @doc """
  Stops a game.
  """
  @spec stop_game(String.t(), Game.player_id()) :: Tally.t()
  def stop_game(player1_name, player_id)
      when is_binary(player1_name) and player_id in @player_ids do
    player1_name |> Server.via() |> GenServer.call({:stop, player_id})
  end

  @doc """
  Adds the second player of a game.
  """
  @spec add_player(String.t(), String.t(), pid) :: Tally.t()
  def add_player(player1_name, player2_name, player2_pid)
      when is_binary(player1_name) and is_binary(player2_name) and
             is_pid(player2_pid) do
    player1_name
    |> Server.via()
    |> GenServer.call({:add_player, player2_name, player2_pid})
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
  def position_island(player1_name, player_id, island_type, row, col)
      when is_binary(player1_name) and player_id in @player_ids and
             island_type in @island_types and row in @board_range and
             col in @board_range do
    player1_name
    |> Server.via()
    |> GenServer.call({:position_island, player_id, island_type, row, col})
  end

  @doc """
  Positions all islands on a player's board.
  """
  @spec position_all_islands(String.t(), Game.player_id()) :: Tally.t()
  def position_all_islands(player1_name, player_id)
      when is_binary(player1_name) and player_id in @player_ids do
    player1_name
    |> Server.via()
    |> GenServer.call({:position_all_islands, player_id})
  end

  @doc """
  Declares all islands set for a player.
  """
  @spec set_islands(String.t(), Game.player_id()) :: Tally.t()
  def set_islands(player1_name, player_id)
      when is_binary(player1_name) and player_id in @player_ids do
    player1_name |> Server.via() |> GenServer.call({:set_islands, player_id})
  end

  @doc """
  Allows a player to guess a coordinate.
  """
  @spec guess_coord(String.t(), Game.player_id(), Coord.row(), Coord.col()) ::
          Tally.t()
  def guess_coord(player1_name, player_id, row, col)
      when is_binary(player1_name) and player_id in @player_ids and
             row in @board_range and col in @board_range do
    player1_name
    |> Server.via()
    |> GenServer.call({:guess_coord, player_id, row, col})
  end

  @doc """
  Returns the tally of a game for a given player.
  """
  @spec tally(String.t(), Game.player_id()) :: Tally.t()
  def tally(player1_name, player_id)
      when is_binary(player1_name) and player_id in @player_ids do
    player1_name |> Server.via() |> GenServer.call({:tally, player_id})
  end
end
