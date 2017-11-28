defmodule IslandsEngine.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :islands_engine,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application() do
    [
      extra_applications: [:logger],
      mod: {IslandsEngine.App, :ok}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps() do
    [
      {:mix_tasks, path: "../mix_tasks", only: :dev, runtime: false},
      {:persist_config, "~> 0.1"},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
