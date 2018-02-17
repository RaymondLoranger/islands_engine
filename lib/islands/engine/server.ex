defmodule Islands.Engine.Server do
  # @moduledoc """
  # Implements an Islands game server.
  # """
  @moduledoc false

  use GenServer, restart: :transient
  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.{Board, Coord, Game, Island, Rules}

  require Logger

  @typep from :: GenServer.from()

  @ets Application.get_env(@app, :ets_name)
  @phrase "saving..."
  @reg Application.get_env(@app, :registry)

  @spec start_link(String.t()) :: GenServer.on_start()
  def start_link(player1_name) when is_binary(player1_name) do
    GenServer.start_link(Server, player1_name, name: via(player1_name))
  end

  @spec via(String.t()) :: {:via, module, {atom, tuple}}
  def via(player1_name), do: {:via, Registry, {@reg, reg_key(player1_name)}}

  ## Private functions

  @spec reg_key(String.t()) :: tuple
  defp reg_key(player1_name), do: {Server, player1_name}

  @spec save(Game.t()) :: Game.t()
  defp save(game) do
    game |> text(@phrase) |> Logger.info()
    true = :ets.insert(@ets, {reg_key(game.player1.name), game})
    game
  end

  @spec text(Game.t(), String.t()) :: String.t()
  defp text(game, phrase) do
    reg_key = game.player1.name |> reg_key() |> inspect()
    self = self() |> inspect()
    game = inspect(game, pretty: true)
    "\n#{reg_key} #{self}\n#{phrase}\n#{game}\n"
  end

  @spec game(String.t()) :: Game.t()
  defp game(player1_name) do
    case :ets.lookup(@ets, reg_key(player1_name)) do
      [] -> Game.new_game(player1_name) |> save()
      [{_key, game}] -> game
    end
  end

  @spec reply(Game.t(), atom | tuple) :: {:reply, atom | tuple, Game.t()}
  defp reply(game, reply), do: {:reply, reply, game}

  ## Callbacks

  @spec init(String.t()) :: {:ok, Game.t()}
  def init(player1_name), do: {:ok, game(player1_name)}

  @spec handle_call(term, from, Game.t()) :: {:reply, atom, Game.t()}
  def handle_call({:add_player, name}, _from, game) do
    with {:ok, rules} <- Rules.check(game.rules, :add_player) do
      game
      |> Game.update_player2_name(name)
      |> Game.update_rules(rules)
      |> reply(:ok)
    else
      :error -> reply(game, :error)
    end
  end

  def handle_call({:position_island, player, key, row, col}, _from, game) do
    board = Game.player_board(game, player)

    with {:ok, rules} <- Rules.check(game.rules, {:position_islands, player}),
         {:ok, coord} <- Coord.new(row, col),
         {:ok, island} <- Island.new(key, coord),
         %{} = board <- Board.position_island(board, island) do
      game
      |> Game.update_board(player, board)
      |> Game.update_rules(rules)
      |> reply(:ok)
    else
      :error -> reply(game, :error)
      {:error, reason} -> reply(game, {:error, reason})
    end
  end

  def handle_call({:set_islands, player}, _from, game) do
    board = Game.player_board(game, player)

    with {:ok, rules} <- Rules.check(game.rules, {:set_islands, player}),
         true <- Board.all_islands_positioned?(board) do
      game
      |> Game.update_rules(rules)
      |> reply({:ok, board})
    else
      :error -> reply(game, :error)
      false -> reply(game, {:error, :not_all_islands_positioned})
    end
  end

  def handle_call({:guess_coordinate, player_key, row, col}, _from, state) do
    opponent_key = Game.opponent(player_key)
    opponent_board = Game.player_board(state, opponent_key)

    with {:ok, rules} <-
           Rules.check(state.rules, {:guess_coordinate, player_key}),
         {:ok, coord} <- Coord.new(row, col),
         {hit_or_miss, forested_island, win_status, opponent_board} <-
           Board.guess(opponent_board, coord),
         {:ok, rules} <- Rules.check(rules, {:win_check, win_status}) do
      state
      |> Game.update_board(opponent_key, opponent_board)
      |> Game.update_guesses(player_key, hit_or_miss, coord)
      |> Game.update_rules(rules)
      |> reply({hit_or_miss, forested_island, win_status})
    else
      :error ->
        {:reply, :error, state}

      {:error, :invalid_coordinate} ->
        {:reply, {:error, :invalid_coordinate}, state}
    end
  end
end
