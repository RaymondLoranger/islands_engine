defmodule Islands.Engine.Proxy.Error do
  @moduledoc false

  use PersistConfig,
    files: ["config/dev.exs", "config/prod.exs", "config/test.exs"]

  require Logger

  @spec log(atom, tuple) :: :ok
  def log(event, details) do
    log? = Application.get_env(@app, :log?)
    do_log(event, details, log?)
  end

  ## Private functions

  @spec do_log(atom, tuple, boolean) :: :ok
  defp do_log(_event, _details, false = _log?), do: :ok

  defp do_log(:exit, {reason}, true = _log?) do
    Logger.remove_backend(:console, flush: true)

    Logger.error("""
    \n`exit` caught...
    • Reason:
    #{inspect(reason)}
    """)

    Logger.add_backend(:console, flush: true)
    :ok
  end
end
