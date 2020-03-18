defmodule Islands.Engine.Guards do
  @moduledoc """
  Defines guards for the Islands Engine API.
  """

  @coord_range 1..10
  @genders [:f, :m]
  @island_types [:atoll, :dot, :l_shape, :s_shape, :square]
  @player_ids [:player1, :player2]

  defguard valid_player_args(game_name, player_id)
           when is_binary(game_name) and player_id in @player_ids

  defguard valid_player_args(game_name, player_name, gender, pid)
           when is_binary(game_name) and is_binary(player_name) and
                  gender in @genders and is_pid(pid)

  defguard valid_player_args(game_name, player_id, player_name, gender, pid)
           when is_binary(game_name) and player_id in @player_ids and
                  is_binary(player_name) and gender in @genders and is_pid(pid)

  defguard valid_island_args(game_name, player_id, island_type, row, col)
           when is_binary(game_name) and player_id in @player_ids and
                  island_type in @island_types and row in @coord_range and
                  col in @coord_range

  defguard valid_coord_args(game_name, player_id, row, col)
           when is_binary(game_name) and player_id in @player_ids and
                  row in @coord_range and col in @coord_range
end
