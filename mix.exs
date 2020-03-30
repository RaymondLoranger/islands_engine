defmodule Islands.Engine.Mixfile do
  use Mix.Project

  def project do
    [
      app: :islands_engine,
      version: "0.2.35",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      name: "Islands Engine",
      source_url: source_url(),
      description: description(),
      package: package(),
      deps: deps()
      # dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  defp source_url do
    "https://github.com/RaymondLoranger/islands_engine"
  end

  defp description do
    """
    Models the Game of Islands.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "config/persist*.exs"],
      maintainers: ["Raymond Loranger"],
      licenses: ["MIT"],
      links: %{"GitHub" => source_url()}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Islands.Engine.Top, :ok}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_tasks,
       github: "RaymondLoranger/mix_tasks", only: :dev, runtime: false},
      {:logger_file_backend, "~> 0.0.9"},
      {:log_reset, "~> 0.1"},
      {:file_only_logger, "~> 0.1"},
      {:dynamic_supervisor_proxy, "~> 0.1"},
      {:gen_server_proxy, "~> 0.1"},
      {:persist_config, "~> 0.2", runtime: false},
      {:islands_board, "~> 0.1"},
      {:islands_board_cache, "~> 0.1"},
      {:islands_coord, "~> 0.1"},
      {:islands_game, "~> 0.1"},
      {:islands_grid, "~> 0.1"},
      {:islands_guesses, "~> 0.1"},
      {:islands_island, "~> 0.1"},
      {:islands_player, "~> 0.1"},
      {:islands_player_id, "~> 0.1"},
      {:islands_request, "~> 0.1"},
      {:islands_response, "~> 0.1"},
      {:islands_score, "~> 0.1"},
      {:islands_state, "~> 0.1"},
      {:islands_tally, "~> 0.1"},
      {:io_ansi_plus, "~> 0.1"},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
