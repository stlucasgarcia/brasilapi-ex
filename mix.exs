defmodule Brasilapi.MixProject do
  use Mix.Project

  def project do
    [
      app: :brasilapi,
      name: "BrasilAPI",
      version: "0.1.0",
      elixir: "~> 1.18",
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/stlucasgarcia/brasilapi-ex",
      homepage_url: "https://github.com/stlucasgarcia/brasilapi-ex",
      deps: deps(),
      docs: [extras: ["README.md"]]
    ]
  end

  defp package do
    [
      maintainers: ["Lucas Garcia"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://www.github.com/stlucasgarcia/brasilapi-ex",
      }
    ]
  end

  defp description do
    """
    A simple Elixir client for BrasilAPI, a public API that provides access to various Brazilian data such as postal codes, states, cities, and more.
    """
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
      {:req, "~> 0.5.0"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false, warn_if_outdated: true},
      {:bypass, "~> 2.1", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
    ]
  end
end
