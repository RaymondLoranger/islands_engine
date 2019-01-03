defmodule GenServer.Proxy.Callback do
  @behaviour GenServer.Proxy.Behaviour

  alias IO.ANSI.Plus, as: ANSI
  alias Islands.Engine.Game.Server

  @impl GenServer.Proxy.Behaviour
  @spec server_name(String.t()) :: GenServer.name()
  def server_name(game_name), do: Server.via(game_name)

  @impl GenServer.Proxy.Behaviour
  @spec server_unregistered(String.t()) :: :ok
  def server_unregistered(game_name) do
    ANSI.puts([
      :fuchsia_background,
      :light_white,
      "Game ",
      :fuchsia_background,
      :stratos,
      "#{game_name}",
      :fuchsia_background,
      :light_white,
      " not started."
    ])
  end
end
