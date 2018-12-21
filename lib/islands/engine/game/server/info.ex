defmodule Islands.Engine.Game.Server.Info do
  @moduledoc false

  use PersistConfig

  alias Islands.Engine.Game.Server

  require Logger

  @log? Application.get_env(@app, :log?)

  @spec log(atom, tuple) :: :ok
  def log(event, details), do: do_log(event, details, @log?)

  ## Private functions

  @dialyzer {:nowarn_function, do_log: 3}
  @spec do_log(atom, tuple, boolean) :: :ok
  defp do_log(_event, _details, false = _log?), do: :ok

  defp do_log(:save, {game}, true = _log?) do
    removed = Logger.remove_backend(:console, flush: true)

    """
    \n#{game.name |> Server.via() |> inspect()} #{self() |> inspect()}
    `handle_call` request...
    #{inspect(game.request, pretty: true)}
    game being saved...
    #{inspect(game, pretty: true)}
    """
    |> Logger.info()

    if removed == :ok, do: Logger.add_backend(:console, flush: true)
    :ok
  end

  defp do_log(:terminate, {reason, game}, true = _log?) do
    removed = Logger.remove_backend(:console, flush: true)

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

    if removed == :ok, do: Logger.add_backend(:console, flush: true)
    :ok
  end
end
