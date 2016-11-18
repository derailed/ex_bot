defmodule ExBot.Mixfile do
  use Mix.Project

  def project do
    [
      app:             :ex_bot,
      version:         "0.1.0",
      elixir:          "~> 1.3",
      build_embedded:  Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps:            deps()
    ]
  end

  def application do
    [
      applications: [:logger, :elixir_ale],
      mod:          {ExBot, []}
    ]
  end

  defp deps do
    [
      {:elixir_ale, "~> 0.5.5"}
    ]
  end
end
