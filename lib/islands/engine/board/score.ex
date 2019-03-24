defmodule Islands.Engine.Board.Score do
  @moduledoc "Convenience module for client applications."

  use PersistConfig

  alias __MODULE__
  alias Islands.Engine.Game.Tally
  alias Islands.Engine.Game
  alias Islands.{Board, Engine, Island}

  @enforce_keys [:type, :hits, :misses, :forested]
  defstruct [:type, :hits, :misses, :forested]

  @type t :: %Score{
          type: :board_side | :guesses_side,
          hits: non_neg_integer,
          misses: non_neg_integer,
          forested: [Island.type()]
        }

  @player_ids Application.get_env(@app, :player_ids)

  @spec board_side(String.t(), Game.player_id()) :: t
  def board_side(game_name, player_id)
      when is_binary(game_name) and player_id in @player_ids do
    new(game_name, player_id, :board_side)
  end

  @spec guesses_side(String.t(), Game.player_id()) :: t
  def guesses_side(game_name, player_id)
      when is_binary(game_name) and player_id in @player_ids do
    new(game_name, Game.opponent(player_id), :guesses_side)
  end

  ## Private functions

  @spec new(String.t(), Game.player_id(), atom) :: t
  defp new(game_name, player_id, type) do
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
end
