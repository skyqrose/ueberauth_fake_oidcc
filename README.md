# UeberauthFakeOidcc

An implementation of [Ueberauth.Strategy](https://hexdocs.pm/ueberauth/Ueberauth.Strategy.html) for use in development environments, which allows specifying email and groups on each login.

TODO screenshot

## Installation

```elixir
# mix.exs
def deps do
  [
    {:ueberauth_fake_oidcc, [github: "skyqrose/ueberauth_fake_oidcc", only: :dev, :test]},
  ]
end

# config/dev.exs and config/test.exs
config :ueberauth, Ueberauth,
  providers: [
    keycloak: {Ueberauth.Strategy.FakeOidcc, [
      client_id: "dev-client-id",
      groups: [
        "group1",
        "group2",
      ]
    ]}
  ]
```

TODO:
Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ueberauth_fake_oidcc>.
