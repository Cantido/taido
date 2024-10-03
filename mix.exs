defmodule Taido.MixProject do
  use Mix.Project

  def project do
    [
      app: :taido,
      name: "Taido",
      description: "A library for building and running behavior trees.",
      source_url: "https://github.com/Cantido/taido",
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        licenses: ["AGPL-3.0-or-later"],
        links: %{
          "GitHub" => "https://github.com/Cantido/taido"
        }
      ],
      docs: [
        main: "Taido"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end
end
