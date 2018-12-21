defmodule Islands.Engine.Proxy.Error do
  @moduledoc false

  alias Islands.Engine.App

  require Logger

  @spec log(atom, tuple) :: :ok
  def log(event, details), do: do_log(event, details, App.log?())

  ## Private functions

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
