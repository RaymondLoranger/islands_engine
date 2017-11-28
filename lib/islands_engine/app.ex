defmodule IslandsEngine.App do
  @moduledoc false

  use Application

  @me __MODULE__

  @spec start(Application.start_type, term) :: {:ok, pid}
  def start(_type, :ok) do
    # List all child processes to be supervised
    [
    ]
    |> Supervisor.start_link(name: @me, strategy: :one_for_one)
  end
end
