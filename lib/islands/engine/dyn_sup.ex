defmodule Islands.Engine.DynSup do
  @moduledoc """
  A supervisor that starts game server processes dynamically.
  """

  use DynamicSupervisor.Proxy

  alias __MODULE__

  @spec start_link(term) :: Supervisor.on_start()
  def start_link(:ok), do: start_link(DynSup, :ok, name: DynSup)

  ## Callbacks

  @spec init(term) :: {:ok, DynamicSupervisor.sup_flags()} | :ignore
  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)
end
