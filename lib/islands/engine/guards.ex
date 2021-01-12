defmodule Islands.Engine.Guards do
  @moduledoc """
  Defines guards for the Islands Engine API.
  """

  @genders [:f, :m]
  @island_types [:atoll, :dot, :l_shape, :s_shape, :square]
  @player_ids [:player1, :player2]

  defguard valid?(game_name, player_id)
           when is_binary(game_name) and player_id in @player_ids

  defguard valid?(game_name, player_name, gender, pid)
           when is_binary(game_name) and is_binary(player_name) and
                  gender in @genders and is_pid(pid)

  @doc """
  No range check on `row` or `col`: island can be dropped partly outside board.
  """
  defguard valid?(game_name, player_id, island_type, row, col)
           when is_binary(game_name) and player_id in @player_ids and
                  island_type in @island_types and is_integer(row) and
                  is_integer(col)

  @doc """
  No range check on `row` or `col`: island can be dropped partly outside board.
  """
  defguard valid_args?(game_name, player_id, row, col)
           when is_binary(game_name) and player_id in @player_ids and
                  is_integer(row) and is_integer(col)
end
