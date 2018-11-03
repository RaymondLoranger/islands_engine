defmodule Islands.Engine.Game.DynSup do
  use DynamicSupervisor

  alias __MODULE__

  @time_in_ms 10

  @spec start_link(term) :: Supervisor.on_start()
  def start_link(:ok),
    do: DynamicSupervisor.start_link(DynSup, :ok, name: maybe_wait(DynSup))

  ## Private functions

  # On restarts, wait if name still registered...
  @spec maybe_wait(atom) :: atom
  defp maybe_wait(name) do
    case Process.whereis(name) do
      nil ->
        name

      _pid ->
        Process.sleep(@time_in_ms)
        maybe_wait(name)
    end
  end

  ## Callbacks

  @spec init(term) :: {:ok, DynamicSupervisor.sup_flags()} | :ignore
  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)
end
