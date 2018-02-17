defmodule Islands.Engine.Sup do
  @moduledoc false

  use DynamicSupervisor

  alias __MODULE__

  @spec start_link(term) :: Supervisor.on_start()
  def start_link(:ok), do: DynamicSupervisor.start_link(Sup, :ok, name: Sup)

  ## Callbacks

  @dialyzer {:nowarn_function, init: 1}
  @spec init(term) :: {:ok, DynamicSupervisor.sup_flags()} | :ignore
  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)
end
