defmodule Islands.Engine.Board.Server do
  use GenServer
  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.Board

  @typep from :: GenServer.from()

  @board_set_path Application.get_env(@app, :board_set_path)

  @spec start_link(term) :: GenServer.on_start()
  def start_link(:ok), do: GenServer.start_link(Server, :ok, name: Server)

  @spec persist_board(Board.t()) :: :ok
  def persist_board(%Board{} = board),
    do: GenServer.cast(Server, {:persist_board, board})

  @spec restore_board :: Board.t()
  def restore_board, do: GenServer.call(Server, :restore_board)

  ## Callbacks

  @spec init(term) :: {:ok, term}
  def init(:ok), do: {:ok, :ok}

  @spec handle_cast(term, term) :: {:noreply, term}
  def handle_cast({:persist_board, board}, :ok) do
    :ok =
      @board_set_path
      |> File.write!(
        case File.read(@board_set_path) do
          {:ok, binary} -> :erlang.binary_to_term(binary)
          {:error, _reason} -> MapSet.new()
        end
        |> MapSet.put(board)
        |> :erlang.term_to_binary()
      )

    {:noreply, :ok}
  end

  @spec handle_call(term, from, term) :: {:reply, Board.t(), term}
  def handle_call(:restore_board, _from, :ok) do
    board =
      @board_set_path
      |> File.read!()
      |> :erlang.binary_to_term()
      |> MapSet.to_list()
      |> Enum.random()

    {:reply, board, :ok}
  end
end
