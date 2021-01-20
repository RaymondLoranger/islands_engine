defmodule Islands.Engine.GameServer do
  @moduledoc """
  A server process that holds a `game` struct as its state.
  """

  use GenServer, restart: :transient
  use PersistConfig

  alias __MODULE__

  alias __MODULE__.{
    AddPlayer,
    GuessCoord,
    PositionAllIslands,
    PositionIsland,
    ReplyTuple,
    SetIslands,
    Stop
  }

  alias Islands.Engine.Log
  alias Islands.{Game, Player, Request}

  @ets get_env(:ets_name)
  # @reg get_env(:registry)
  @timeout get_env(:timeout)
  @wait 50

  @spec start_link({Game.name(), Player.name(), Player.gender(), pid}) ::
          GenServer.on_start()
  def start_link({game_name, player1_name, gender, pid} = _init_arg) do
    GenServer.start_link(
      GameServer,
      {game_name, player1_name, gender, pid},
      name: via(game_name)
    )
  end

  # @spec via(Game.name()) :: {:via, module, {atom, tuple}}
  # def via(game_name), do: {:via, Registry, {@reg, key(game_name)}}

  @spec via(Game.name()) :: {:global, tuple}
  def via(game_name), do: {:global, key(game_name)}

  @spec save(Game.t()) :: Game.t()
  def save(game) do
    :ok = Log.info(:save, {game})
    true = :ets.insert(@ets, {key(game.name), game})
    game
  end

  ## Private functions

  @spec key(Game.name()) :: tuple
  defp key(game_name), do: {GameServer, game_name}

  @spec game(Game.name(), Player.name(), Player.gender(), pid) :: Game.t()
  defp game(game_name, player1_name, gender, pid) do
    case :ets.lookup(@ets, key(game_name)) do
      [] ->
        :ok = Log.info(:spawned, {game_name, player1_name})
        Game.new(game_name, player1_name, gender, pid) |> save()

      [{_key, game}] ->
        :ok = Log.info(:restarted, {game_name, player1_name})
        game
    end
  end

  ## Callbacks

  @spec init({Game.name(), Player.name(), Player.gender(), pid}) ::
          {:ok, Game.t(), timeout}
  def init({game_name, player1_name, gender, pid} = _init_arg),
    do: {:ok, game(game_name, player1_name, gender, pid), @timeout}

  @spec handle_call(Request.t(), GenServer.from(), Game.t()) :: ReplyTuple.t()
  def handle_call({:add_player, _, _, _} = request, from, game),
    do: AddPlayer.handle_call(request, from, game)

  def handle_call({:position_island, _, _, _, _} = request, from, game),
    do: PositionIsland.handle_call(request, from, game)

  def handle_call({:position_all_islands, _} = request, from, game),
    do: PositionAllIslands.handle_call(request, from, game)

  def handle_call({:stop, _} = request, from, game),
    do: Stop.handle_call(request, from, game)

  def handle_call({:set_islands, _} = request, from, game),
    do: SetIslands.handle_call(request, from, game)

  def handle_call({:guess_coord, _, _, _} = request, from, game),
    do: GuessCoord.handle_call(request, from, game)

  def handle_call({:tally, player_id}, _from, game),
    do: ReplyTuple.new(game, player_id)

  @spec handle_info(term, Game.t()) ::
          {:stop, reason :: tuple, Game.t()} | {:noreply, Game.t()}
  def handle_info(:timeout, game) do
    :ok = Log.info(:timeout, {@timeout, game})
    {:stop, {:shutdown, :timeout}, game}
  end

  def handle_info(_message, game), do: {:noreply, game}

  @spec terminate(term, Game.t()) :: :ok
  def terminate(:shutdown = reason, game) do
    :ok = Log.info(:terminate, {reason, game})
    true = :ets.delete(@ets, key(game.name))
    # Ensure message logged before exiting...
    Process.sleep(@wait)
  end

  def terminate(reason, game) do
    :ok = Log.error(:terminate, {reason, game})
    true = :ets.delete(@ets, key(game.name))
    # Ensure message logged before exiting...
    Process.sleep(@wait)
  end
end
