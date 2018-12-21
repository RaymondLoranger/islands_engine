defmodule Islands.Engine.Game.Server.Info do
  @moduledoc false

  use PersistConfig,
    files: ["config/dev.exs", "config/prod.exs", "config/test.exs"]

  alias Islands.Engine.Game.Server

  require Logger

  @spec log(atom, tuple) :: :ok
  def log(event, details) do
    log? = Application.get_env(@app, :log?)
    do_log(event, details, log?)
  end

  ## Private functions

  @spec do_log(atom, tuple, boolean) :: :ok
  defp do_log(_event, _details, false = _log?), do: :ok

  defp do_log(:save, {game}, true = _log?) do
    Logger.remove_backend(:console, flush: true)

    """
    \n#{game.name |> Server.via() |> inspect()} #{self() |> inspect()}
    `handle_call` request...
    #{inspect(game.request, pretty: true)}
    game being saved...
    #{inspect(game, pretty: true)}
    """
    |> Logger.info()

    Logger.add_backend(:console, flush: true)
    :ok
  end

  defp do_log(:terminate, {reason, game}, true = _log?) do
    Logger.remove_backend(:console, flush: true)

    """
    \n#{game.name |> Server.via() |> inspect()} #{self() |> inspect()}
    `handle_call` request...
    #{inspect(game.request, pretty: true)}
    `terminate` reason...
    #{inspect(reason, pretty: true)}
    game being terminated...
    #{inspect(game, pretty: true)}
    """
    |> Logger.info()

    Logger.add_backend(:console, flush: true)
    :ok
  end
end
