defmodule DummyTest.MixProject do
  use Mix.Project

  def project do
    [
      app: :dummy_test,
      config: "./config/config.exs",
      version: "0.1.0",
      elixir: "~> 1.10-rc",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: ["lib"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:uex, path: "../", in_umbrella: true},
      {:mogrify, "~> 0.7.3"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
