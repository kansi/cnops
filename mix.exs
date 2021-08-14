defmodule Cnops.MixProject do
  use Mix.Project

  def project do
    [
      app: :cnops,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Cnops.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:control_node, "~> 0.6.0"},
      {:quantum, "~> 3.0"},
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.17.0"},
      {:jason, ">= 1.0.0"}
    ]
  end
end
