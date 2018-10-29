defmodule Islands.Engine.Sup do
  @moduledoc false

  use Supervisor

  alias Islands.Engine.Game.Server.Restart
  alias Islands.Engine.Game.Sup
  alias Islands.Engine.Sup, as: EngineSup

  @spec start_link(term) :: Supervisor.on_start()
  def start_link(:ok),
    do: Supervisor.start_link(EngineSup, :ok, name: EngineSup, timeout: 10_000)

  ## Callbacks

  @spec init(term) ::
          {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}} | :ignore
  def init(:ok) do
    [
      # Child spec relying on use DynamicSupervisor...
      {Sup, :ok},

      # Child spec relying on use GenServer...
      {Restart, :ok}
    ]
    |> Supervisor.init(strategy: :rest_for_one)
  end
end
