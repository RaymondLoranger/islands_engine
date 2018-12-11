defmodule Islands.Engine.Game.DynSup do
  @moduledoc """
  A supervisor that starts game server processes dynamically.
  """

  use DynamicSupervisor

  alias __MODULE__

  @timeout 10
  @times 5

  @spec start_link(term) :: Supervisor.on_start()
  def start_link(:ok) do
    case DynamicSupervisor.start_link(DynSup, :ok, name: DynSup) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, _pid}} ->
        DynamicSupervisor.start_link(DynSup, :ok, name: wait(DynSup, @times))
    end
  end

  ## Private functions

  # On restarts, wait if name still registered...
  @spec wait(atom, non_neg_integer) :: atom
  defp wait(name, 0), do: name

  defp wait(name, times_left) do
    Process.sleep(@timeout)

    case Process.whereis(name) do
      nil -> name
      pid when is_pid(pid) -> wait(name, times_left - 1)
    end
  end

  ## Callbacks

  @spec init(term) :: {:ok, DynamicSupervisor.sup_flags()} | :ignore
  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)
end
