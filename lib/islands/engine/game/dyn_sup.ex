defmodule Islands.Engine.Game.DynSup do
  @moduledoc false

  use DynamicSupervisor

  alias __MODULE__

  @spec start_link(term) :: Supervisor.on_start()
  def start_link(:ok),
    do: DynamicSupervisor.start_link(DynSup, :ok, name: DynSup, timeout: 10_000)

  ## Callbacks

  @spec init(term) :: {:ok, DynamicSupervisor.sup_flags()} | :ignore
  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)
end
