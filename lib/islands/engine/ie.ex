defmodule Islands.Engine.IE do
  @moduledoc false

  # Functions for iex session...
  #
  # Examples:
  #   use Islands.Engine.IE
  #   print_square_colors()
  #   print_boards()

  #   use Islands.Engine.IE
  #   guesses = Guesses.new()
  #   {:ok, coord1} = Coord.new(1, 1)
  #   {:ok, coord2} = Coord.new(2, 2)
  #   guesses = update_in(guesses.hits, &MapSet.put(&1, coord1))
  #   guesses = update_in(guesses.hits, &MapSet.put(&1, coord2))
  #   guesses = update_in(guesses.hits, &MapSet.put(&1, coord1))
  #   {:ok, coord} = Coord.new(4, 6)
  #   Island.new(:l_shape, coord)
  #   Island.new(:wrong, coord)
  #   {:ok, coord} = Coord.new(10, 10)
  #   Island.new(:l_shape, coord)
  #   Island.new(:dot, coord)

  use PersistConfig

  # alias __MODULE__
  alias IO.ANSI
  alias IO.ANSI.Table
  # alias IO.ANSI.Table.Style
  # alias Islands.Engine.{Board, Coord, Game, Guesses, Island}

  @board_range Application.get_env(@app, :board_range)

  @i "#{ANSI.format([:light_yellow, :light_yellow_background, "isl"], true)}"
  @f "#{ANSI.format([:green, :green_background, "for"], true)}"
  @w "#{ANSI.format([:blue, :blue_background, "wat"], true)}"
  @h "#{ANSI.format([:green, :green_background, "hit"], true)}"
  @m "#{ANSI.format([:light_black, :light_black_background, "mis"], true)}"

  @square_colors %{
    "a" => @i,
    "d" => @i,
    "l" => @i,
    "q" => @i,
    "s" => @i,
    "A" => @f,
    "D" => @f,
    "L" => @f,
    "Q" => @f,
    "S" => @f,
    "H" => @h,
    "m" => @m,
    "" => @w
  }

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      alias unquote(__MODULE__)

      alias Islands.Engine.{
        Board,
        Coord,
        DemoProc,
        Game,
        Guesses,
        Island,
        Rules
      }

      :ok
    end
  end

  def print_square_colors() do
    IO.puts("island: #{@i}")
    IO.puts("forest: #{@f}")
    IO.puts("water : #{@w}")
    IO.puts("hit   : #{@h}")
    IO.puts("miss  : #{@m}")
  end

  def print_boards() do
    board =
      for row <- @board_range, into: %{} do
        {
          row,
          for col <- @board_range, into: %{} do
            {col, ""}
          end
        }
      end

    guess = board

    board |> populate_board() |> ready_board() |> print_board()
    guess |> populate_guess() |> ready_board() |> print_guess()

    :ok
  end

  def print_board(board) do
    Table.format(
      board,
      bell: false,
      count: 10,
      style: :game,
      headers: ["row", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      header_fixes: %{"Row" => ""},
      align_specs: [
        right: "row",
        center: 1,
        center: 2,
        center: 3,
        center: 4,
        center: 5,
        center: 6,
        center: 7,
        center: 8,
        center: 9,
        center: 10
      ],
      sort_specs: ["row"],
      sort_symbols: [asc: ""]
    )
  end

  def print_guess(board) do
    Table.format(
      board,
      bell: false,
      count: 10,
      style: :game,
      headers: ["row", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      header_fixes: %{"Row" => ""},
      align_specs: [
        right: "row",
        center: 1,
        center: 2,
        center: 3,
        center: 4,
        center: 5,
        center: 6,
        center: 7,
        center: 8,
        center: 9,
        center: 10
      ],
      sort_specs: ["row"],
      sort_symbols: [asc: ""],
      margins: [left: 35, top: -12]
    )
  end

  def populate_board(board) do
    board
    |> put_in([1, 1], "a")
    |> put_in([1, 2], "A")
    |> put_in([2, 2], "A")
    |> put_in([3, 1], "a")
    |> put_in([3, 2], "A")
    |> put_in([3, 7], "l")
    |> put_in([4, 7], "l")
    |> put_in([5, 7], "L")
    |> put_in([5, 8], "l")
    |> put_in([6, 3], "s")
    |> put_in([6, 4], "s")
    |> put_in([7, 2], "s")
    |> put_in([7, 3], "s")
    |> put_in([9, 5], "q")
    |> put_in([9, 6], "q")
    |> put_in([9, 9], "D")
    |> put_in([10, 5], "q")
    |> put_in([10, 6], "q")
  end

  def populate_guess(guess) do
    guess
    |> put_in([1, 2], "m")
    |> put_in([3, 4], "H")
    |> put_in([3, 5], "H")
    |> put_in([4, 7], "H")
    |> put_in([5, 3], "m")
    |> put_in([5, 8], "H")
    |> put_in([7, 10], "m")
    |> put_in([8, 4], "m")
    |> put_in([9, 3], "H")
    |> put_in([9, 4], "m")
  end

  def ready_board(board) do
    for {row_num, row_map} <- board do
      [
        {"row", row_num}
        | for {col_num, square} <- row_map do
            {col_num, @square_colors[square]}
          end
      ]
      |> Map.new()
    end
  end
end
