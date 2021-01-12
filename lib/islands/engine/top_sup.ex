defmodule Islands.Engine.TopSup do
  use Application
  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.{DynGameSup, GameRecovery}

  @ets get_env(:ets_name)
  # @reg get_env(:registry)

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_type, :ok) do
    :ets.new(@ets, [:public, :named_table])

    [
      # Child spec relying on `use DynamicSupervisor`...
      {DynGameSup, :ok},
      # Child spec relying on `use GenServer`...
      {GameRecovery, :ok}
    ]
    |> Supervisor.start_link(name: TopSup, strategy: :rest_for_one)
  end
end
