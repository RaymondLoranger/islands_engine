defmodule Islands.Engine.Top do
  @moduledoc false

  use Application
  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.Server.Restart
  alias Islands.Engine.DynSup

  @ets Application.get_env(@app, :ets_name)
  # @reg Application.get_env(@app, :registry)

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_type, :ok) do
    :ets.new(@ets, [:public, :named_table])

    [
      # Child spec relying on `use DynamicSupervisor`...
      {DynSup, :ok},
      # Child spec relying on `use GenServer`...
      {Restart, :ok}
    ]
    |> Supervisor.start_link(name: Top, strategy: :rest_for_one)
  end
end
