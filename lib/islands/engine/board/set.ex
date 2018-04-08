defmodule Islands.Engine.Board.Set do
  @moduledoc false

  use PersistConfig

  alias Islands.Engine.Board

  @board_set_path Application.get_env(@app, :board_set_path)

  @spec persist_board(Board.t()) :: :ok
  def persist_board(%Board{} = board) do
    @board_set_path
    |> File.write!(
      case File.read(@board_set_path) do
        {:ok, binary} -> :erlang.binary_to_term(binary)
        {:error, _reason} -> MapSet.new()
      end
      |> MapSet.put(board)
      |> :erlang.term_to_binary()
    )
  end

  @spec restore_board :: Board.t()
  def restore_board do
    @board_set_path
    |> File.read!()
    |> :erlang.binary_to_term()
    |> MapSet.to_list()
    |> Enum.random()
  end
end
