defmodule Ratdec.MixProject do
  use Mix.Project

  def project do
    [
      app: :ratdec,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      escript: [main_module: Ratdec],
      deps: []
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]
end
