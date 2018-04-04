defmodule Islands.Engine.Server.Error do
  @moduledoc false

  require Logger

  @spec log(any, any) :: :ok
  def log(non_matched_value, request) do
    Logger.error("""
    \n`handle_call` request:
    #{inspect(request, pretty: true)}
    \n`with` non-matched value:
    #{inspect(non_matched_value, pretty: true)}
    """)
  end
end
