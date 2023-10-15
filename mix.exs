defmodule LiveViewNativeFlutterUi.MixProject do
  use Mix.Project

  def project do
    [
      app: :live_view_native_flutter_ui,
      version: "0.1.1",
      elixir: "~> 1.15",
      description: "LiveView Native platform for FlutterUI",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools, :live_view_native_platform]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.2"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:live_view_native_platform, "~> 0.1"},
      {:phoenix, "~> 1.7.7"},
      {:phoenix_live_view, "~> 0.19.0"}
    ]
  end

  @source_url "https://github.com/alex-min/live_view_native_flutter_ui"

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
