defmodule Islands.Engine.Proxy.Error do
  @moduledoc false

  require Logger

  @spec log(atom, term, tuple) :: :ok
  def log(:exit, reason, caller) do
    Logger.error("""
    \n`exit` caught for calling function #{inspect(caller)}...
    `exit` reason:
    #{inspect(reason)}
    """)
  end
end
