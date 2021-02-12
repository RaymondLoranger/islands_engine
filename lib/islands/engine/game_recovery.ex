defmodule Islands.Engine.GameRecovery do
  use GenServer
  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.{DynGameSup, GameServer}
  alias Islands.Game

  @ets get_env(:ets_name)

  @spec start_link(term) :: GenServer.on_start()
  def start_link(:ok),
    do: GenServer.start_link(GameRecovery, :ok, name: GameRecovery)

  ## Private functions

  @spec restart_servers :: :ok
  defp restart_servers do
    @ets
    |> :ets.match_object({{GameServer, :_}, :_})
    |> Enum.each(fn {{GameServer, _game_name}, game} ->
      player1 = game.player1
      # Child may already be started...
      DynamicSupervisor.start_child(
        DynGameSup,
        {GameServer, {game.name, player1.name, player1.gender, player1.pid}}
      )
    end)
  end

  ## Callbacks

  @spec init(term) :: {:ok, term}
  def init(:ok), do: {:ok, restart_servers()}

  @spec handle_call(term, GenServer.from(), term) ::
          {:reply, [Game.overview()], term}
  def handle_call(:game_overviews, _from, :ok) do
    game_overviews =
      @ets
      |> :ets.match_object({{GameServer, :_}, :_})
      |> Enum.map(fn {{GameServer, _game_name}, game} ->
        Game.overview(game)
      end)
      |> Enum.sort()

    {:reply, game_overviews, :ok}
  end
end
