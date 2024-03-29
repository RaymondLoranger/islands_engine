defmodule Islands.Engine.GenServerProxy do
  @behaviour GenServer.Proxy

  alias IO.ANSI.Plus, as: ANSI
  alias Islands.Engine.GameServer
  alias Islands.Game

  # @impl GenServer.Proxy
  @spec server_name(Game.name()) :: GenServer.name()
  defdelegate server_name(game_name), to: GameServer, as: :via

  # @impl GenServer.Proxy
  @spec server_unregistered(Game.name()) :: :ok
  def server_unregistered(game_name) do
    ANSI.puts([
      :fuchsia_background,
      :light_white,
      "Islands Game ",
      :italic,
      "#{game_name}",
      :not_italic,
      " not started."
    ])
  end
end
