defmodule Islands.Engine.Board.Score do
  @moduledoc "Convenience module for client applications."

  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.Game.Tally
  alias Islands.Engine.{Board, Game, Island}
  alias Islands.Engine

  @enforce_keys [:type, :hits, :misses, :forested]
  defstruct [:type, :hits, :misses, :forested]

  @type t :: %Score{
          type: :player | :opponent,
          hits: non_neg_integer,
          misses: non_neg_integer,
          forested: [Island.type()]
        }

  @player_ids Application.get_env(@app, :player_ids)

  @spec new(String.t(), Game.player_id(), atom) :: t
  def new(game_name, player_id, type)
      when is_binary(game_name) and player_id in @player_ids and
             type in [:player, :opponent] do
    player_id =
      case type do
        :player -> player_id
        :opponent -> Game.opponent(player_id)
      end

    %Tally{board: board} = Engine.tally(game_name, player_id)
    %Board{islands: islands, misses: misses} = board

    %Score{
      type: type,
      hits:
        islands
        |> Map.values()
        |> Enum.map(&MapSet.size(&1.hits))
        |> Enum.sum(),
      misses: MapSet.size(misses),
      forested:
        islands
        |> Map.values()
        |> Enum.filter(&Island.forested?/1)
        |> Enum.map(& &1.type)
    }
  end

  def new(_game_name, _player_id, _type), do: {:error, :invalid_score_args}
end
