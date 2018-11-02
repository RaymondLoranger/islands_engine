defmodule Islands.Engine.Game.DynSup do
  use DynamicSupervisor

  alias __MODULE__

  @spec start_link(term) :: Supervisor.on_start()
  def start_link(:ok),
    do: DynamicSupervisor.start_link(DynSup, :ok, name: DynSup)

  ## Callbacks

  @spec init(term) :: {:ok, DynamicSupervisor.sup_flags()} | :ignore
  def init(:ok),
    # Max restarts per time frame of 5 seconds defaults to 3 times...
    do: DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 9)
end
