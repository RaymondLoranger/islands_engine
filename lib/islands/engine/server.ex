defmodule Islands.Engine.Server do
  @moduledoc """
  A server process that holds a `game` struct as its state.
  """

  use GenServer, restart: :transient
  use PersistConfig

  alias __MODULE__

  alias __MODULE__.{
    AddPlayer,
    GuessCoord,
    Log,
    PositionAllIslands,
    PositionIsland,
    SetIslands,
    Stop
  }

  alias Islands.{Game, Player, PlayerID, Request, Tally}

  @ets Application.get_env(@app, :ets_name)
  # @reg Application.get_env(@app, :registry)
  @wait 50

  @type from :: GenServer.from()
  @type reply :: {:reply, Tally.t(), Game.t()}

  @spec start_link({String.t(), String.t(), Player.gender(), pid}) ::
          GenServer.on_start()
  def start_link({game_name, player1_name, gender, pid}) do
    GenServer.start_link(
      Server,
      {game_name, player1_name, gender, pid},
      name: via(game_name)
    )
  end

  # @spec via(String.t()) :: {:via, module, {atom, tuple}}
  # def via(game_name), do: {:via, Registry, {@reg, key(game_name)}}

  @spec via(String.t()) :: {:global, tuple}
  def via(game_name), do: {:global, key(game_name)}

  @spec save(Game.t()) :: Game.t()
  def save(game) do
    :ok = Log.info(:save, {game})
    true = :ets.insert(@ets, {key(game.name), game})
    game
  end

  @spec reply(Game.t(), PlayerID.t()) :: reply
  def reply(game, player_id), do: {:reply, Tally.new(game, player_id), game}

  ## Private functions

  @spec key(String.t()) :: tuple
  defp key(game_name), do: {Server, game_name}

  @spec game(String.t(), String.t(), Player.gender(), pid) :: Game.t()
  defp game(game_name, player1_name, gender, pid) do
    case :ets.lookup(@ets, key(game_name)) do
      [] -> game_name |> Game.new(player1_name, gender, pid) |> save()
      [{_key, game}] -> game
    end
  end

  ## Callbacks

  @spec init({String.t(), String.t(), Player.gender(), pid}) :: {:ok, Game.t()}
  def init({game_name, player1_name, gender, pid}),
    do: {:ok, game(game_name, player1_name, gender, pid)}

  @spec handle_call(Request.t(), from, Game.t()) :: reply
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

  def handle_call({:tally, player_id}, _from, game), do: reply(game, player_id)

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
