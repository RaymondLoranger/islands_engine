use Mix.Config

config :islands_engine, board_range: 1..10
config :islands_engine, ets_name: Islands.Engine.Ets

config :islands_engine,
  island_types: [:atoll, :dot, :l_shape, :s_shape, :square]

config :islands_engine, player_ids: [:player1, :player2]
# config :islands_engine, registry: Islands.Engine.Reg
