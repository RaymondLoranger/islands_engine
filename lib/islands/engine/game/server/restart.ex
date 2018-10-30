defmodule Islands.Engine.Game.Server.Restart do
  @moduledoc false

  use GenServer
  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.Game.{Server, Sup}

  @ets Application.get_env(@app, :ets_name)

  @spec start_link(term) :: GenServer.on_start()
  def start_link(:ok),
    do: GenServer.start_link(Restart, :ok, name: Restart, timeout: 10_000)

  ## Private functions

  @spec restart_servers :: :ok
  defp restart_servers do
    @ets
    |> :ets.match_object({{Server, :_}, :_})
    |> Enum.each(fn {{Server, player1_name}, _game} ->
      # Child may already be started...
      DynamicSupervisor.start_child(Sup, {Server, player1_name})
    end)
  end

  ## Callbacks

  @spec init(term) :: {:ok, term}
  def init(:ok), do: {:ok, restart_servers()}
end
