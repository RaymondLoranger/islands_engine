defmodule Islands.Engine.Server.Error do
  @moduledoc false

  require Logger

  @spec log(atom, any, any) :: :ok
  def log(:handle_call, non_matched_value, request) do
    """

    `handle_call` request:
    #{inspect(request, pretty: true)}

    `with` non-matched value:
    #{inspect(non_matched_value, pretty: true)}
    """
    |> Logger.error()
  end

  def log(:terminate, reason, game) do
    """

    `terminate` reason:
    #{inspect(reason)}

    `game` to clean up:
    #{inspect(game, pretty: true)}
    """
    |> Logger.error()
  end
end
