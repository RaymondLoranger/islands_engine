defmodule Islands.Engine.TopSup do
  use Application
  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.{DynGameSup, GameRecovery}

  @ets get_env(:ets_name)
  # @reg get_env(:registry)

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_start_type, _start_args = :ok) do
    :ets.new(@ets, [:public, :named_table])

    [
      # {Registry, keys: :unique, name: @reg},

      # Child spec relying on `use DynamicSupervisor`...
      {DynGameSup, :ok},

      # Child spec relying on `use GenServer`...
      {GameRecovery, :ok}
    ]
    # NOTE: Strategy...                              ↓ ↓ ↓ ↓ ↓ ↓ ↓
    |> Supervisor.start_link(name: TopSup, strategy: :rest_for_one)
  end
end
