defmodule Islands.Engine.Log do
  use File.Only.Logger

  alias Islands.Engine.Game.Server

  error :handle_call, {non_matched_value, request, game} do
    """
    \n'with' non-matched value on 'handle_call'...
    • Server:
      #{game.name |> Server.via() |> inspect(pretty: true)}
    • Server PID: #{self() |> inspect(pretty: true)}
    • 'handle_call' request:
      #{inspect(request, pretty: true)}
    • 'with' non-matched value:
      #{inspect(non_matched_value, pretty: true)}
    • Game being processed:
      #{inspect(game, pretty: true)}
    • App: #{:application.get_application() |> elem(1)}
    • Library: #{Application.get_application(__MODULE__)}
    • Module: #{inspect(__MODULE__)}
    """
  end

  error :terminate, {reason, game} do
    """
    \nTerminating game...
    • Server:
      #{game.name |> Server.via() |> inspect(pretty: true)}
    • Server PID: #{self() |> inspect(pretty: true)}
    • 'handle_call' request:
      #{inspect(game.request, pretty: true)}
    • 'terminate' reason: #{inspect(reason, pretty: true)}
    • Game being terminated:
      #{inspect(game, pretty: true)}
    • App: #{:application.get_application() |> elem(1)}
    • Library: #{Application.get_application(__MODULE__)}
    • Module: #{inspect(__MODULE__)}
    """
  end

  info :terminate, {reason, game} do
    """
    \nTerminating game...
    • Server:
      #{game.name |> Server.via() |> inspect(pretty: true)}
    • Server PID: #{self() |> inspect(pretty: true)}
    • 'handle_call' request:
      #{inspect(game.request, pretty: true)}
    • 'terminate' reason: #{inspect(reason, pretty: true)}
    • Game being terminated:
      #{inspect(game, pretty: true)}
    • App: #{:application.get_application() |> elem(1)}
    • Library: #{Application.get_application(__MODULE__)}
    • Module: #{inspect(__MODULE__)}
    """
  end

  info :save, {game} do
    """
    \nSaving game...
    • Server:
      #{game.name |> Server.via() |> inspect(pretty: true)}
    • Server PID: #{self() |> inspect(pretty: true)}
    • 'handle_call' request:
      #{inspect(game.request, pretty: true)}
    • Game being saved:
      #{inspect(game, pretty: true)}
    • App: #{:application.get_application() |> elem(1)}
    • Library: #{Application.get_application(__MODULE__)}
    • Module: #{inspect(__MODULE__)}
    """
  end
end
