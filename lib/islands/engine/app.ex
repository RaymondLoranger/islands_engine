defmodule Islands.Engine.App do
  use Application
  use PersistConfig

  alias __MODULE__
  alias __MODULE__.LogReset
  alias Islands.Engine.Board.Server
  alias Islands.Engine.Sup

  @ets Application.get_env(@app, :ets_name)
  # @reg Application.get_env(@app, :registry)

  @error_path Application.get_env(:logger, :error_log)[:path]
  @info_path Application.get_env(:logger, :info_log)[:path]

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_type, :ok) do
    unless Mix.env() == :test do
      [@error_path, @info_path] |> Enum.each(&LogReset.clear_log/1)
    end

    :ets.new(@ets, [:public, :named_table])

    [
      # Child spec relying on use GenServer...
      {Server, :ok},
      # Child spec relying on use Supervisor...
      {Sup, :ok}
    ]
    |> Supervisor.start_link(name: App, strategy: :one_for_one)
  end
end
