defmodule Flagship.MixProject do
  use Mix.Project

  @version "0.3.2"
  @source_url "https://github.com/jackpocket/flagship"

  def project do
    [
      app: :flagship,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      docs: docs(),
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
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
      {:ex_doc, "~> 0.31.2"},
      {:ldclient, "~> 3.1", hex: :launchdarkly_server_sdk}
    ]
  end

  defp description do
    """
    Flagship is a library with tools for working with feature flags in Elixir.
    """
  end

  defp package do
    [
      name: "flagship",
      maintainers: ["Todd Resudek"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url},
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"]
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "Flagship",
      logo: "logo.png",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
