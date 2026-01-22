defmodule UeberauthFakeOidcc.MixProject do
  use Mix.Project

  def project do
    [
      app: :ueberauth_fake_oidcc,
      version: "0.1.0",
      elixir: ">= 1.17.0 and < 2.0.0",
      deps: deps()
    ]
  end

  defp deps do
    [
      # needed for showing the fake login page (but you were probably using Phoenix anyway)
      {:phoenix, "~> 1.7"},
      {:phoenix_live_view, "~> 1.0"},
      {:ueberauth, "~> 0.10"},
      {:ueberauth_oidcc, "~> 0.4"}
    ]
  end
end
