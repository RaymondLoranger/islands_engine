defmodule Islands.Engine.App do
  @moduledoc false

  use Application
  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.Board.Server
  alias Islands.Engine.Sup

  @ets Application.get_env(@app, :ets_name)
  # @reg Application.get_env(@app, :registry)

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_type, :ok) do
    :ets.new(@ets, [:public, :named_table])

    [
      # Child spec relying on use GenServer...
      {Server, :ok},
      # Child spec relying on use Supervisor...
      {Sup, :ok}
    ]
    |> Supervisor.start_link(name: App, strategy: :one_for_one)
  end

  @spec log? :: boolean
  def log?, do: Application.get_env(@app, :log?)
end
