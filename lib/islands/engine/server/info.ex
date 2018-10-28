defmodule Islands.Engine.Server.Info do
  @moduledoc false
  alias Islands.Engine.Server

  require Logger

  @spec log(atom, any) :: :ok
  def log(:save, game) do
    """
    \n#{game.player1.name |> Server.via() |> inspect()} #{self() |> inspect()}
    `handle_call` request...
    #{inspect(game.request, pretty: true)}
    game being saved...
    #{inspect(game, pretty: true)}
    """
    |> Logger.info()
  end

  @spec log(atom, any, any) :: :ok
  def log(:terminate, reason, game) do
    """
    \n#{game.player1.name |> Server.via() |> inspect()} #{self() |> inspect()}
    `handle_call` request...
    #{inspect(game.request, pretty: true)}
    `terminate` reason...
    #{inspect(reason, pretty: true)}
    game being terminated...
    #{inspect(game, pretty: true)}
    """
    |> Logger.info()
  end
end
