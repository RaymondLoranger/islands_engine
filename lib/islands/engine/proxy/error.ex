defmodule Islands.Engine.Proxy.Error do
  @moduledoc false

  use PersistConfig

  require Logger

  @log? Application.get_env(@app, :log?)

  @spec log(atom, tuple) :: :ok
  def log(event, details), do: do_log(event, details, @log?)

  ## Private functions

  @dialyzer {:nowarn_function, do_log: 3}
  @spec do_log(atom, tuple, boolean) :: :ok
  defp do_log(_event, _details, false = _log?), do: :ok

  defp do_log(:exit, {reason}, true = _log?) do
    removed = Logger.remove_backend(:console, flush: true)

    Logger.error("""
    \n`exit` caught...
    • Reason:
    #{inspect(reason)}
    """)

    if removed == :ok, do: Logger.add_backend(:console, flush: true)
    :ok
  end
end
