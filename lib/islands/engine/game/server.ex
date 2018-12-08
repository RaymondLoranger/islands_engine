defmodule Islands.Engine.Game.Server do
  use GenServer, restart: :transient
  use PersistConfig

  alias __MODULE__

  alias __MODULE__.{
    AddPlayer,
    Error,
    GuessCoord,
    Info,
    PositionAllIslands,
    PositionIsland,
    SetIslands,
    Stop
  }

  alias Islands.Engine.Game.Tally
  alias Islands.Engine.Game

  @type from :: GenServer.from()
  @type reply :: {:reply, Tally.t(), Game.t()}
  @type request :: tuple
  @type response :: tuple

  @ets Application.get_env(@app, :ets_name)
  # @reg Application.get_env(@app, :registry)
  @timeout_in_ms 500

  @spec start_link({String.t(), String.t(), pid}) :: GenServer.on_start()
  def start_link({game_name, player1_name, pid}) do
    import GenServer, only: [start_link: 3]
    start_link(Server, {game_name, player1_name, pid}, name: via(game_name))
  end

  # @spec via(String.t()) :: {:via, module, {atom, tuple}}
  # def via(game_name), do: {:via, Registry, {@reg, key(game_name)}}

  @spec via(String.t()) :: {:global, tuple}
  def via(game_name), do: {:global, key(game_name)}

  @spec save(Game.t()) :: Game.t()
  def save(game) do
    :ok = Info.log(:save, game)
    true = :ets.insert(@ets, {key(game.name), game})
    game
  end

  @spec reply(Game.t(), Game.player_id()) :: reply
  def reply(game, player_id), do: {:reply, Tally.new(game, player_id), game}

  ## Private functions

  @spec key(String.t()) :: tuple
  defp key(game_name), do: {Server, game_name}

  @spec game(String.t(), String.t(), pid) :: Game.t()
  defp game(game_name, player1_name, pid) do
    case :ets.lookup(@ets, key(game_name)) do
      [] -> game_name |> Game.new(player1_name, pid) |> save()
      [{_key, game}] -> game
    end
  end

  ## Callbacks

  @spec init({String.t(), String.t(), pid}) :: {:ok, Game.t()}
  def init({game_name, player1_name, pid}),
    do: {:ok, game(game_name, player1_name, pid)}

  @spec handle_call(request, from, Game.t()) :: reply
  def handle_call({:add_player, _, _} = request, from, game),
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

  def handle_call({:tally, player_id}, _from, game), do: reply(game, player_id)

  @spec terminate(term, Game.t()) :: :ok
  def terminate(:shutdown = reason, game) do
    :ok = Info.log(:terminate, reason, game)
    true = :ets.delete(@ets, key(game.name))
    # Ensure message logged before exiting...
    Process.sleep(@timeout_in_ms)
  end

  def terminate(reason, game) do
    :ok = Error.log(:terminate, reason, game)
    true = :ets.delete(@ets, key(game.name))
    # Ensure message logged before exiting...
    Process.sleep(@timeout_in_ms)
  end
end
