defmodule UeberauthFakeOidcc.MixProject do
  use Mix.Project

  def project do
    [
      app: :ueberauth_fake_oidcc,
      version: "0.1.0",
      elixir: "~> 1.19",
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
      # needed for showing the fake login page (but you were probably using Phoenix anyway)
      {:phoenix, "~> 1.7"},
      {:ueberauth, "~> 0.10"},
      {:ueberauth_oidcc, "~> 0.4"},
    ]
  end
end
