defmodule Islands.Engine.Proxy.Error do
  @moduledoc false

  require Logger

  @spec log(atom, term) :: :ok
  def log(:exit, reason) do
    Logger.error("""
    \n`exit` caught...
    • Reason:
    #{inspect(reason)}
    """)
  end
end
