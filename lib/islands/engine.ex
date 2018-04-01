# ┌────────────────────────────────────────────────────────────────────┐
# │ Based on the book "Functional Web Development" by Lance Halvorsen. │
# └────────────────────────────────────────────────────────────────────┘
defmodule Islands.Engine do
  use PersistConfig

  @book_ref Application.get_env(@app, :book_ref)

  @moduledoc """
  Models an Islands game.

  ##### #{@book_ref}
  """

  alias __MODULE__.{Coord, Game, Island, Server, Sup, Tally}

  @board_range Application.get_env(@app, :board_range)
  @island_types Application.get_env(@app, :island_types)
  @player_ids Application.get_env(@app, :player_ids)

  @doc """
  Starts a new game.

  ## Examples

      iex> alias Islands.Engine
      iex> me = self()
      iex> {:ok, game_id} = Engine.new_game("Meg", me)
      iex> {:error, {:already_started, ^game_id}} = Engine.new_game("Meg", me)
      iex> is_pid(game_id)
      true
  """
  @spec new_game(String.t(), pid) :: Supervisor.on_start_child()
  def new_game(player1_name, player1_pid)
      when is_binary(player1_name) and is_pid(player1_pid) do
    DynamicSupervisor.start_child(Sup, {Server, {player1_name, player1_pid}})
  end

  @doc """
  Ends a game.

  ## Examples

      iex> alias Islands.Engine
      iex> me = self()
      iex> Engine.new_game("Ben", me)
      iex> Engine.end_game("Ben")
      :ok
  """
  @spec end_game(String.t()) :: :ok
  def end_game(player1_name) when is_binary(player1_name) do
    player1_name |> Server.via() |> GenServer.stop(:shutdown)
  end

  @doc """
  Stops a game.

  # ## Examples

  #     iex> alias Islands.Engine
  #     iex> me = self()
  #     iex> Engine.new_game("Ben", me)
  #     iex> Engine.end_game("Ben")
  #     :ok
  """
  @spec stop_game(String.t(), Game.player_id()) :: Tally.t()
  def stop_game(player1_name, player_id)
      when is_binary(player1_name) and player_id in @player_ids do
    player1_name |> Server.via() |> GenServer.call({:stop, player_id})
  end

  @doc """
  Adds the second player of a game.

  ## Examples

      iex> alias Islands.Engine
      iex> alias Islands.Engine.{Grid, Tally}
      iex> him = self()
      iex> her = self()
      iex> {:ok, game_id} = Engine.new_game("Romeo", him)
      iex> tally = Engine.add_player("Romeo", "Juliet", her)
      iex> %Tally{
      ...>   game_state: :players_set,
      ...>   player1_state: :islands_not_set,
      ...>   player2_state: :islands_not_set,
      ...>   request: {:add_player, "Juliet", player2_pid},
      ...>   response: {:ok, :player2_added},
      ...>   board: board,
      ...>   guesses: guesses
      ...> } = tally
      iex> board == Grid.new() and guesses == Grid.new() and
      ...> player2_pid == her and is_pid(game_id)
      true
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

  # Examples

      iex> alias Islands.Engine
      iex> alias Islands.Engine.{Grid, Tally}
      iex> her = self()
      iex> him = self()
      iex> {:ok, game_id} = Engine.new_game("Bonnie", her)
      iex> Engine.add_player("Bonnie", "Clyde", him)
      iex> tally = Engine.position_island("Bonnie", :player2, :atoll, 1, 1)
      iex> %Tally{
      ...>   game_state: :players_set,
      ...>   player1_state: :islands_not_set,
      ...>   player2_state: :islands_not_set,
      ...>   request: {:position_island, :player2, :atoll, 1, 1},
      ...>   response: {:ok, :island_positioned},
      ...>   board: board,
      ...>   guesses: guesses
      ...> } = tally
      iex> is_map(board) and guesses == Grid.new() and is_pid(game_id)
      true
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
  Declares all islands set for a player.

  ## Examples

      iex> alias Islands.Engine
      iex> alias Islands.Engine.{Grid, Tally}
      iex> him = self()
      iex> her = self()
      iex> {:ok, game_id} = Engine.new_game("Adam", him)
      iex> Engine.add_player("Adam", "Eve", her)
      iex> Engine.position_island("Adam", :player2, :atoll, 1, 1)
      iex> tally = Engine.set_islands("Adam", :player2)
      iex> %Tally{
      ...>   game_state: :players_set,
      ...>   player1_state: :islands_not_set,
      ...>   player2_state: :islands_not_set,
      ...>   request: {:set_islands, :player2},
      ...>   response: {:error, :not_all_islands_positioned},
      ...>   board: board,
      ...>   guesses: guesses
      ...> } = tally
      iex> is_map(board) and guesses == Grid.new() and is_pid(game_id)
      true

      iex> alias Islands.Engine
      iex> alias Islands.Engine.{Grid, Tally}
      iex> her = self()
      iex> him = self()
      iex> {:ok, game_id} = Engine.new_game("Mary", her)
      iex> Engine.add_player("Mary", "Joseph", him)
      iex> Engine.position_island("Mary", :player2, :atoll, 1, 1)
      iex> Engine.position_island("Mary", :player2, :l_shape, 3, 7)
      iex> Engine.position_island("Mary", :player2, :s_shape, 6, 2)
      iex> Engine.position_island("Mary", :player2, :square, 9, 5)
      iex> Engine.position_island("Mary", :player2, :dot, 9, 9)
      iex> tally = Engine.set_islands("Mary", :player2)
      iex> %Tally{
      ...>   game_state: :players_set,
      ...>   player1_state: :islands_not_set,
      ...>   player2_state: :islands_set,
      ...>   request: {:set_islands, :player2},
      ...>   response: {:ok, :islands_set},
      ...>   board: board,
      ...>   guesses: guesses
      ...> } = tally
      iex> is_map(board) and guesses == Grid.new() and is_pid(game_id)
      true
  """
  @spec set_islands(String.t(), Game.player_id()) :: Tally.t()
  def set_islands(player1_name, player_id)
      when is_binary(player1_name) and player_id in @player_ids do
    player1_name |> Server.via() |> GenServer.call({:set_islands, player_id})
  end

  @doc """
  Allows a player to guess a coordinate.

  # ## Examples

      iex> alias Islands.Engine
      iex> alias Islands.Engine.{Grid, Tally}
      iex> him = self()
      iex> her = self()
      iex> {:ok, game_id} = Engine.new_game("Caesar", him)
      iex> Engine.add_player("Caesar", "Cleopatra", her)
      iex> Engine.position_island("Caesar", :player2, :atoll, 1, 1)
      iex> Engine.position_island("Caesar", :player2, :l_shape, 3, 7)
      iex> Engine.position_island("Caesar", :player2, :s_shape, 6, 2)
      iex> Engine.position_island("Caesar", :player2, :square, 9, 5)
      iex> Engine.position_island("Caesar", :player2, :dot, 9, 9)
      iex> Engine.set_islands("Caesar", :player2)
      iex> tally = Engine.guess_coord("Caesar", :player1, 9, 9)
      iex> %Tally{
      ...>   game_state: :players_set,
      ...>   player1_state: :islands_not_set,
      ...>   player2_state: :islands_set,
      ...>   request: {:guess_coord, :player1, 9, 9},
      ...>   response: {:error, :islands_not_set},
      ...>   board: board,
      ...>   guesses: guesses
      ...> } = tally
      iex> board == Grid.new() and guesses == Grid.new() and is_pid(game_id)
      true

      iex> alias Islands.Engine
      iex> alias Islands.Engine.{Grid, Tally}
      iex> him = self()
      iex> her = self()
      iex> {:ok, game_id} = Engine.new_game("Tristan", him)
      iex> Engine.add_player("Tristan", "Iseult", her)
      iex> Engine.position_island("Tristan", :player2, :atoll, 1, 1)
      iex> Engine.position_island("Tristan", :player2, :l_shape, 3, 7)
      iex> Engine.position_island("Tristan", :player2, :s_shape, 6, 2)
      iex> Engine.position_island("Tristan", :player2, :square, 9, 5)
      iex> Engine.position_island("Tristan", :player2, :dot, 9, 9)
      iex> Engine.set_islands("Tristan", :player2)
      iex> Engine.position_island("Tristan", :player1, :atoll, 1, 1)
      iex> Engine.position_island("Tristan", :player1, :l_shape, 3, 7)
      iex> Engine.position_island("Tristan", :player1, :s_shape, 6, 2)
      iex> Engine.position_island("Tristan", :player1, :square, 9, 5)
      iex> Engine.position_island("Tristan", :player1, :dot, 9, 9)
      iex> Engine.set_islands("Tristan", :player1)
      iex> tally = Engine.guess_coord("Tristan", :player1, 9, 9)
      iex> %Tally{
      ...>   game_state: :player2_turn,
      ...>   player1_state: :islands_set,
      ...>   player2_state: :islands_set,
      ...>   request: {:guess_coord, :player1, 9, 9},
      ...>   response: {:hit, :dot, :no_win},
      ...>   board: board,
      ...>   guesses: guesses
      ...> } = tally
      iex> is_map(board) and is_map(guesses) and is_pid(game_id)
      true
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

  # Examples

      iex> alias Islands.Engine
      iex> alias Islands.Engine.{Grid, Tally}
      iex> him = self()
      iex> {:ok, game_id} = Engine.new_game("Jim", him)
      iex> tally = Engine.tally("Jim", :player1)
      iex> %Tally{
      ...>   game_state: :initialized,
      ...>   player1_state: :islands_not_set,
      ...>   player2_state: :islands_not_set,
      ...>   request: {},
      ...>   response: {},
      ...>   board: board,
      ...>   guesses: guesses
      ...> } = tally
      iex> board == Grid.new() and guesses == Grid.new() and is_pid(game_id)
      true
  """
  @spec tally(String.t(), Game.player_id()) :: Tally.t()
  def tally(player1_name, player_id)
      when is_binary(player1_name) and player_id in @player_ids do
    player1_name |> Server.via() |> GenServer.call({:tally, player_id})
  end
end
