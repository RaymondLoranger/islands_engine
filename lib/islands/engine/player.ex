defmodule Islands.Engine.Player do
  @moduledoc false

  alias __MODULE__
  alias Islands.Engine.{Board, Guesses}

  @enforce_keys [:name, :board, :guesses]
  defstruct [:name, :pid, :board, :guesses]

  @type t :: %Player{
          name: String.t(),
          pid: pid | nil,
          board: Board.t(),
          guesses: Guesses.t()
        }

  @spec new(String.t(), Board.t(), Guesses.t()) :: t
  def new(name, board \\ Board.new(), guesses \\ Guesses.new())

  def new(name, %Board{} = board, %Guesses{} = guesses) when is_binary(name),
    do: %Player{name: name, board: board, guesses: guesses}

  def new(_name, _board, _guesses), do: {:error, :invalid_player_args}

  @spec update_player_pid(t, pid) :: t
  def update_player_pid(%Player{} = player, pid) when is_pid(pid),
    do: put_in(player.pid, pid)
end
