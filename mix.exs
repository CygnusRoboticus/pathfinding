defmodule Pathfinding.MixProject do
  use Mix.Project

  @version "0.1.1"
  @url "https://github.com/CygnusRoboticus/pathfinding"

  def project do
    [
      name: "Pathfinding",
      app: :pathfinding,
      version: @version,
      elixir: "~> 1.7",
      build_embedded: Mix.env() === :prod,
      start_permanent: Mix.env() == :prod,
      description: "Tile-based A* Pathfinding",
      package: package(),
      deps: deps(),
      source_url: @url,
      homepage_url: @url
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      files: ~w(lib LICENSE mix.exs README.md),
      licenses: ["MIT"],
      links: %{"github" => @url}
    ]
  end

  defp deps do
    [
      {:heap, "~> 2.0"},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
