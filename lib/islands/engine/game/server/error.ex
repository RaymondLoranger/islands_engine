defmodule Islands.Engine.Game.Server.Error do
  @moduledoc false

  use PersistConfig,
    files: ["config/dev.exs", "config/prod.exs", "config/test.exs"]

  alias Islands.Engine.Game.Server
  alias Islands.Engine.Game

  require Logger

  @spec log(atom, tuple) :: :ok
  def log(event, details) do
    log? = Application.get_env(@app, :log?)
    do_log(event, details, log?)
  end

  @spec reply(Game.t(), Server.request(), atom, Game.player_id()) ::
          Server.reply()
  def reply(game, request, reason, player_id) do
    game
    |> Game.update_request(request)
    |> Game.update_response({:error, reason})
    |> Server.save()
    |> Server.reply(player_id)
  end

  ## Private functions

  @spec do_log(atom, tuple, boolean) :: :ok
  defp do_log(_event, _details, false = _log?), do: :ok

  defp do_log(:handle_call, {non_matched_value, request, game}, true = _log?) do
    :ok = Logger.remove_backend(:console, flush: true)

    :ok =
      """
      \n#{game.name |> Server.via() |> inspect()} #{self() |> inspect()}
      `handle_call` request...
      #{inspect(request, pretty: true)}
      `with` non-matched value...
      #{inspect(non_matched_value, pretty: true)}
      game being processed...
      #{inspect(game, pretty: true)}
      """
      |> Logger.error()

    {:ok, _pid} = Logger.add_backend(:console, flush: true)
    :ok
  end

  defp do_log(:terminate, {reason, game}, true) do
    :ok = Logger.remove_backend(:console, flush: true)

    :ok =
      """
      \n#{game.name |> Server.via() |> inspect()} #{self() |> inspect()}
      `handle_call` request...
      #{inspect(game.request, pretty: true)}
      `terminate` reason...
      #{inspect(reason, pretty: true)}
      game being terminated...
      #{inspect(game, pretty: true)}
      """
      |> Logger.error()

    {:ok, _pid} = Logger.add_backend(:console, flush: true)
    :ok
  end
end
