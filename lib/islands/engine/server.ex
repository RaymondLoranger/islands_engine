defmodule Islands.Engine.Server do
  @moduledoc false

  use GenServer, restart: :transient
  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.{Board, Coord, Error, Game, Island, State, Tally}

  require Logger

  @typep from :: GenServer.from()

  @ets Application.get_env(@app, :ets_name)
  @phrase "saving..."
  # @reg Application.get_env(@app, :registry)

  @spec start_link({String.t(), pid}) :: GenServer.on_start()
  def start_link({player1_name, pid}) do
    GenServer.start_link(Server, {player1_name, pid}, name: via(player1_name))
  end

  # @spec via(String.t()) :: {:via, module, {atom, tuple}}
  # def via(player1_name), do: {:via, Registry, {@reg, key(player1_name)}}

  @spec via(String.t()) :: {:global, tuple}
  def via(player1_name), do: {:global, key(player1_name)}

  ## Private functions

  @spec key(String.t()) :: tuple
  defp key(player1_name), do: {Server, player1_name}

  @spec save(Game.t()) :: Game.t()
  defp save(game) do
    game |> text() |> Logger.info()
    true = :ets.insert(@ets, {key(game.player1.name), game})
    game
  end

  @spec text(Game.t(), String.t()) :: String.t()
  defp text(game, phrase \\ @phrase) do
    key = game.player1.name |> key() |> inspect()
    self = self() |> inspect()
    game = inspect(game, pretty: true)
    "\n#{key} #{self}\n#{phrase}\n#{game}\n"
  end

  @spec game(String.t(), pid) :: Game.t()
  defp game(player1_name, pid) do
    case :ets.lookup(@ets, key(player1_name)) do
      [] ->
        player1_name
        |> Game.new()
        |> Game.update_player_pid(:player1, pid)
        |> save()

      [{_key, game}] ->
        game
    end
  end

  @spec reply(Game.t(), Game.player_id()) :: {:reply, Tally.t(), Game.t()}
  defp reply(game, player_id), do: {:reply, Tally.new(game, player_id), game}

  ## Callbacks

  @spec init({String.t(), pid}) :: {:ok, Game.t()}
  def init({player1_name, pid}), do: {:ok, game(player1_name, pid)}

  @spec handle_call(term, from, Game.t()) :: {:reply, Tally.t(), Game.t()}
  def handle_call({:add_player = action, name, pid}, _from, game) do
    with {:ok, state} <- State.check(game.state, action) do
      game
      |> Game.update_player2_name(name)
      |> Game.update_player_pid(:player2, pid)
      |> Game.update_state(state)
      |> Game.update_request({action, name, pid})
      |> Game.update_response({:ok, :player2_added})
      |> Game.notify_player(:player1)
      |> save()
      |> reply(:player2)
    else
      :error ->
        game
        |> Game.update_request({action, name, pid})
        |> Game.update_response({:error, :player2_already_added})
        |> save()
        |> reply(:player2)
    end
  end

  def handle_call(
        {:position_island = action, player_id, island_type, row, col} = request,
        _from,
        game
      ) do
    with {:ok, state} <- State.check(game.state, {action, player_id}),
         {:ok, origin} <- Coord.new(row, col),
         {:ok, island} <- Island.new(island_type, origin),
         %Board{} = board <- Game.player_board(game, player_id),
         %Board{} = board <- Board.position_island(board, island) do
      response =
        {:ok,
         board
         |> Board.all_islands_positioned?()
         |> if(do: :all_islands_positioned, else: :island_positioned)}

      game
      |> Game.update_board(player_id, board)
      |> Game.update_state(state)
      |> Game.update_request(request)
      |> Game.update_response(response)
      |> save()
      |> reply(player_id)
    else
      :error ->
        game
        |> Game.update_request(request)
        |> Game.update_response({:error, :islands_already_set})
        |> save()
        |> reply(player_id)

      {:error, reason} ->
        game
        |> Game.update_request(request)
        |> Game.update_response({:error, reason})
        |> save()
        |> reply(player_id)

      non_matched_value ->
        Error.log(non_matched_value, request)

        game
        |> Game.update_request(request)
        |> Game.update_response({:error, :unknown})
        |> save()
        |> reply(player_id)
    end
  end

  def handle_call({:stop = action, player_id}, _from, game) do
    with {:ok, state} <- State.check(game.state, action) do
      opponent_id = Game.opponent(player_id)

      game
      |> Game.update_state(state)
      |> Game.update_request({action, player_id})
      |> Game.update_response({:ok, :stopping})
      |> Game.notify_player(opponent_id)
      |> save()
      |> reply(player_id)
    else
      :error ->
        game
        |> Game.update_request({action, player_id})
        |> Game.update_response({:error, :islands_not_set})
        |> save()
        |> reply(player_id)
    end
  end

  def handle_call({:set_islands = action, player_id}, _from, game) do
    with {:ok, state} <- State.check(game.state, {action, player_id}),
         %{} = board <- Game.player_board(game, player_id),
         true <- Board.all_islands_positioned?(board) do
      opponent_id = Game.opponent(player_id)

      game
      |> Game.update_state(state)
      |> Game.update_request({action, player_id})
      |> Game.update_response({:ok, :islands_set})
      |> Game.notify_player(opponent_id)
      |> save()
      |> reply(player_id)
    else
      :error ->
        game
        |> Game.update_request({action, player_id})
        |> Game.update_response({:error, :both_players_islands_set})
        |> save()
        |> reply(player_id)

      false ->
        game
        |> Game.update_request({action, player_id})
        |> Game.update_response({:error, :not_all_islands_positioned})
        |> save()
        |> reply(player_id)

      _other ->
        game
        |> Game.update_request({action, player_id})
        |> Game.update_response({:error, :unknown})
        |> save()
        |> reply(player_id)
    end
  end

  def handle_call({:guess_coord = action, player_id, row, col}, _from, game) do
    with {:ok, state} <- State.check(game.state, {action, player_id}),
         {:ok, guess} <- Coord.new(row, col),
         opponent_id = Game.opponent(player_id),
         %{} = opponent_board <- Game.player_board(game, opponent_id),
         {hit_or_miss, forested_island_type, win_status, opponent_board} <-
           Board.guess(opponent_board, guess),
         {:ok, state} <- State.check(state, {:win_check, win_status}) do
      game
      |> Game.update_board(opponent_id, opponent_board)
      |> Game.update_guesses(player_id, hit_or_miss, guess)
      |> Game.update_state(state)
      |> Game.update_request({action, player_id, row, col})
      |> Game.update_response({hit_or_miss, forested_island_type, win_status})
      |> Game.notify_player(opponent_id)
      |> save()
      |> reply(player_id)
    else
      :error ->
        game
        |> Game.update_request({action, player_id, row, col})
        |> Game.update_response({:error, :islands_not_set})
        |> save()
        |> reply(player_id)

      {:error, reason} ->
        game
        |> Game.update_request({action, player_id, row, col})
        |> Game.update_response({:error, reason})
        |> save()
        |> reply(player_id)

      _other ->
        game
        |> Game.update_request({action, player_id, row, col})
        |> Game.update_response({:error, :unknown})
        |> save()
        |> reply(player_id)
    end
  end

  def handle_call({:tally, player_id}, _from, game) do
    reply(game, player_id)
  end

  @spec terminate(term, Game.t()) :: true
  def terminate(:shutdown, game) do
    true = :ets.delete(@ets, key(game.player1.name))
  end
end
