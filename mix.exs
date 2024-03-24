defmodule LiveViewNative.Flutter.MixProject do
  use Mix.Project

  def project do
    [
      app: :live_view_native_flutter,
      version: "0.1.3",
      elixir: "~> 1.15",
      description: "LiveView Native platform for Flutter",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:jason, "~> 1.2"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:live_view_native,
       github: "liveview-native/live_view_native", branch: "main", override: true},
      {:phoenix, "~> 1.7.7"},
      {:phoenix_live_view, "~> 0.20.0"}
    ]
  end

  @source_url "https://github.com/alex-min/live_view_native_flutter"

  # Hex package configuration
  defp package do
    %{
      maintainers: ["alex-min"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      source_url: @source_url
    }
  end
end
