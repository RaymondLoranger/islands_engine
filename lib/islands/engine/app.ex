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
      # Child spec relying on use GenServer...
      {Server, :ok},
      # Child spec relying on use Supervisor...
      {Sup, :ok}
    ]
    |> Supervisor.start_link(name: App, strategy: :one_for_one)
  end

  ## Private functions

  @spec clear_log(Path.t()) :: :ok
  defp clear_log(log_path) do
    log_path = Path.expand(log_path)
    dir_path = Path.dirname(log_path)

    case File.mkdir_p(dir_path) do
      :ok -> :ok
      {:error, reason} -> error(reason, "Couldn't create directory", dir_path)
    end

    case File.write(log_path, "") do
      :ok -> :ok
      {:error, reason} -> error(reason, "Couldn't clear log file", log_path)
    end
  end

  @spec error(File.posix(), String.t(), Path.t()) :: :ok
  defp error(reason, msg, path) do
    IO.puts("#{msg} #{inspect(path)}:")
    reason |> :file.format_error() |> IO.puts()
  end
end
