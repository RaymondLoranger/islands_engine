defmodule Islands.Engine do
  @moduledoc """
  Models the game of Islands.
  """

  use PersistConfig

  alias __MODULE__.{Game, Server, Sup}

  @board_range Application.get_env(@app, :board_range)
  @players Application.get_env(@app, :players)
  @types Application.get_env(@app, :island_types)

  # @doc """
  # Starts a new game.

  # ## Examples

  #     iex> alias Islands.Engine
  #     iex> {:ok, game_id} = Engine.new_game("Meg")
  #     iex> {:error, {:already_started, ^game_id}} = Engine.new_game("Meg")
  #     iex> is_pid(game_id)
  #     true
  # """
  @spec new_game(String.t(), String.t()) :: Supervisor.on_start_child()
  def new_game(player1, player2)
      when is_binary(player1) and is_binary(player2) do
    DynamicSupervisor.start_child(Sup, {Server, player1})
    player1 |> Server.via() |> GenServer.call({:add_player, player2})
  end

  # @doc """
  # Ends a game.

  # ## Examples

  #     iex> alias Islands.Engine
  #     iex> Engine.new_game("Ben")
  #     iex> Engine.end_game("Ben")
  #     :ok
  # """
  @spec end_game(String.t()) :: :ok
  def end_game(game) when is_binary(game) do
    game |> Server.via() |> GenServer.stop(:shutdown)
  end

  # @doc """
  # Returns the tally of a game.

  # ## Examples

  #     iex> alias Islands.Engine
  #     iex> Engine.new_game("Jim")
  #     iex> tally = Engine.tally("Jim")
  #     iex> %{
  #     ...>   game_state: :initializing,
  #     ...>   turns_left: 7,
  #     ...>   letters: letters
  #     ...> } = tally
  #     iex> all_underscores? = Enum.all?(letters, & &1 == "_")
  #     iex> is_list(letters) and all_underscores?
  #     true
  # """
  @spec tally(String.t(), atom) :: Game.tally()
  def tally(game, player) when is_binary(game) and player in @players do
    game |> Server.via() |> GenServer.call({:tally, player})
  end

  def position_island(game, player, type, row, col)
      when is_binary(game) and player in @players and type in @types and
             row in @board_range and col in @board_range do
    game
    |> Server.via()
    |> GenServer.call({:position_island, player, type, row, col})
  end

  def set_islands(game, player) when is_binary(game) and player in @players do
    game |> Server.via() |> GenServer.call({:set_islands, player})
  end

  # @doc """
  # Makes a move and returns the tally.

  # ## Examples

  #     iex> alias Hangman.Engine
  #     iex> Engine.new_game("Ed")
  #     iex> Engine.make_move("Ed", "a").game_state in [:good_guess, :bad_guess]
  #     true
  # """
  # @spec make_move(String.t(), String.codepoint()) :: Game.tally()
  def guess_coord(game, player, row, col)
      when is_binary(game) and player in @players and row in @board_range and
             col in @board_range do
    game |> Server.via() |> GenServer.call({:guess_coord, player, row, col})
  end
end
