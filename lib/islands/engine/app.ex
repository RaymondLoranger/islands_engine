defmodule Islands.Engine.App do
  use Application
  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.Board.Server
  alias Islands.Engine.Sup

  @ets Application.get_env(@app, :ets_name)
  # @reg Application.get_env(@app, :registry)

  @error_path Application.get_env(:logger, :error_log)[:path]
  @info_path Application.get_env(:logger, :info_log)[:path]
  @warn_path Application.get_env(:logger, :warn_log)[:path]

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_type, :ok) do
    [@error_path, @info_path, @warn_path] |> Enum.each(&clear_log/1)
    :ets.new(@ets, [:public, :named_table])

    [
      # Child spec relying on use Supervisor...
      {Sup, :ok},

      # Child spec relying on use GenServer...
      {Server, :ok}
    ]
    |> Supervisor.start_link(name: App, strategy: :one_for_one)
  end

  ## Private functions

  defp clear_log(log_path) do
    path = Path.expand(log_path)

    case File.write(path, "") do
      :ok ->
        :ok

      {:error, reason} ->
        IO.puts("Couldn't clear log #{inspect(path)}:")
        reason |> :file.format_error() |> IO.puts()
    end
  end
end
