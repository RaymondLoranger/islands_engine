defmodule Islands.Engine.Game do
  @behaviour Access

  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.Game.{Player, Server, State}
  alias Islands.Engine.{Board, Coord, Guesses}

  @enforce_keys [:name, :player1, :player2]
  defstruct name: nil,
            player1: nil,
            player2: nil,
            request: {},
            response: {},
            state: State.new()

  @type player_id :: :player1 | :player2
  @type t :: %Game{
          name: String.t(),
          player1: Player.t(),
          player2: Player.t(),
          request: Server.request(),
          response: Server.response(),
          state: State.t()
        }

  @player_ids Application.get_env(@app, :player_ids)

  # Access behaviour
  defdelegate fetch(game, key), to: Map
  defdelegate get(game, key, default), to: Map
  defdelegate get_and_update(game, key, fun), to: Map
  defdelegate pop(game, key), to: Map

  @spec new(String.t(), String.t(), pid) :: t | {:error, atom}
  def new(name, player1_name, pid)
      when is_binary(name) and is_binary(player1_name) and is_pid(pid) do
    %Game{
      name: name,
      player1: Player.new(player1_name, pid),
      player2: Player.new("?", nil)
    }
  end

  def new(_name, _player1_name, _pid), do: {:error, :invalid_game_args}

  @spec update_board(t, player_id, Board.t()) :: t
  def update_board(%Game{} = game, player_id, %Board{} = board)
      when player_id in @player_ids,
      do: put_in(game[player_id].board, board)

  @spec update_guesses(t, player_id, Guesses.type(), Coord.t()) :: t
  def update_guesses(%Game{} = game, player_id, hit_or_miss, %Coord{} = guess)
      when player_id in @player_ids and hit_or_miss in [:hit, :miss] do
    update_in(game[player_id].guesses, &Guesses.add(&1, hit_or_miss, guess))
  end

  @spec update_player_name(t, player_id, String.t()) :: t
  def update_player_name(%Game{} = game, player_id, name)
      when player_id in @player_ids and is_binary(name),
      do: put_in(game[player_id].name, name)

  @spec update_player_pid(t, player_id, pid) :: t
  def update_player_pid(%Game{} = game, player_id, pid)
      when player_id in @player_ids and is_pid(pid),
      do: put_in(game[player_id].pid, pid)

  @spec notify_player(t, player_id) :: t
  def notify_player(%Game{} = game, player_id) when player_id in @player_ids do
    send(game[player_id].pid, game.state.game_state)
    game
  end

  @spec player_board(t, player_id) :: Board.t()
  def player_board(%Game{} = game, player_id) when player_id in @player_ids,
    do: game[player_id].board

  @spec opponent(player_id) :: player_id
  def opponent(:player1), do: :player2
  def opponent(:player2), do: :player1

  @spec update_state(t, State.t()) :: t
  def update_state(%Game{} = game, %State{} = state),
    do: put_in(game.state, state)

  @spec update_request(t, Server.request()) :: t
  def update_request(%Game{} = game, request) when is_tuple(request),
    do: put_in(game.request, request)

  @spec update_response(t, Server.response()) :: t
  def update_response(%Game{} = game, response) when is_tuple(response),
    do: put_in(game.response, response)
end
