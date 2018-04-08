defmodule Islands.Engine.Server.Error do
  @moduledoc false

  require Logger

  @spec log(any, any) :: :ok
  def log(non_matched_value, request) do
    """

    `handle_call` request:
    #{inspect(request, pretty: true)}

    `with` non-matched value:
    #{inspect(non_matched_value, pretty: true)}
    """
    |> Logger.error()
  end
end
