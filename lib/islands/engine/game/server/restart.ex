defmodule Islands.Engine.Game.Server.Restart do
  use GenServer
  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.Game.{DynSup, Server}

  @ets Application.get_env(@app, :ets_name)

  @spec start_link(term) :: GenServer.on_start()
  def start_link(:ok), do: GenServer.start_link(Restart, :ok, name: Restart)

  ## Private functions

  @spec restart_servers :: :ok
  defp restart_servers do
    @ets
    |> :ets.match_object({{Server, :_}, :_})
    |> Enum.each(fn {{Server, _game_name}, game} ->
      # Child may already be started...
      DynamicSupervisor.start_child(DynSup, {Server, game})
    end)
  end

  ## Callbacks

  @spec init(term) :: {:ok, term}
  def init(:ok), do: {:ok, restart_servers()}
end
