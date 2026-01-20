# UeberauthFakeOidcc

An implementation of [Ueberauth.Strategy](https://hexdocs.pm/ueberauth/Ueberauth.Strategy.html) for use in development environments, which allows specifying email and groups on each login.

TODO screenshot

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ueberauth_fake_oidcc` to your list of dependencies in `mix.exs`:

```elixir
# mix.exs
def deps do
  [
    {:ueberauth_fake_oidcc, [github: "skyqrose/ueberauth_fake_oidcc", only: :dev, :test]}
  ]
end
```

TODO dev.exs configuration

TODO:
Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ueberauth_fake_oidcc>.
