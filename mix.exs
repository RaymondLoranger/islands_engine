defmodule Islands.Engine.Mixfile do
  use Mix.Project

  def project do
    [
      app: :islands_engine,
      version: "0.1.9",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      name: "Islands Engine",
      source_url: source_url(),
      description: description(),
      package: package(),
      deps: deps(),
      dialyzer: [plt_add_apps: [:io_ansi_table]]
    ]
  end

  defp source_url do
    "https://github.com/RaymondLoranger/islands_engine"
  end

  defp description do
    """
    Models an Islands game.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "assets", "config/persist*.exs"],
      maintainers: ["Raymond Loranger"],
      licenses: ["MIT"],
      links: %{"GitHub" => source_url()}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      included_applications: [:io_ansi_table],
      extra_applications: [:logger],
      mod: {Islands.Engine.App, :ok}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_tasks,
       github: "RaymondLoranger/mix_tasks", only: :dev, runtime: false},
      {:persist_config, "~> 0.1"},
      {:io_ansi_table, "~> 0.4"},
      {:logger_file_backend, "~> 0.0.9"},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
