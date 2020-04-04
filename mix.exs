defmodule Uex.MixProject do
  use Mix.Project

  def project do
    [
      app: :uex,
      version: "0.0.1",
      build_path: "./_build",
      config_path: "./config/config.exs",
      deps_path: "./deps",
      lockfile: "./mix.lock",
      elixir: "~> 1.10-rc",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/marucjmar/uex",
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:temp, "~> 0.4"},
      {:httpoison, "~> 1.6"},
      {:plug_cowboy, "~> 2.0"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:jason, "~> 1.1"},
      {:sweet_xml, "~> 0.6"},
      {:elixir_uuid, "~> 1.2"},
      {:faker, "~> 0.13", only: :test},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Composable file upload library for Elixir."
  end

  defp package() do
    [
      name: "uex",
      maintainers: ["Marcin Lazar"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/marucjmar/uex"}
    ]
  end
end
