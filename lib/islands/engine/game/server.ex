defmodule Islands.Engine.Game.Server do
  @moduledoc false

  use GenServer, restart: :transient
  use PersistConfig

  alias __MODULE__

  alias Islands.Engine.Game.Server.{
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

  @spec start_link({String.t(), pid}) :: GenServer.on_start()
  def start_link({player1_name, pid}) do
    GenServer.start_link(Server, {player1_name, pid}, name: via(player1_name))
  end

  # @spec via(String.t()) :: {:via, module, {atom, tuple}}
  # def via(player1_name), do: {:via, Registry, {@reg, key(player1_name)}}

  @spec via(String.t()) :: {:global, tuple}
  def via(player1_name), do: {:global, key(player1_name)}

  @spec save(Game.t()) :: Game.t()
  def save(game) do
    :ok = Info.log(:save, game)
    true = :ets.insert(@ets, {key(game.player1.name), game})
    game
  end

  @spec reply(Game.t(), Game.player_id()) :: reply
  def reply(game, player_id), do: {:reply, Tally.new(game, player_id), game}

  ## Private functions

  @spec key(String.t()) :: tuple
  defp key(player1_name), do: {Server, player1_name}

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

  ## Callbacks

  @spec init({String.t(), pid}) :: {:ok, Game.t()}
  def init({player1_name, pid}), do: {:ok, game(player1_name, pid)}

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

  @spec terminate(term, Game.t()) :: true
  def terminate(:shutdown = reason, game) do
    :ok = Info.log(:terminate, reason, game)
    true = :ets.delete(@ets, key(game.player1.name))
  end

  def terminate(reason, game) do
    :ok = Error.log(:terminate, reason, game)
    true = :ets.delete(@ets, key(game.player1.name))
  end
end
