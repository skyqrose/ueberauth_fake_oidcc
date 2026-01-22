defmodule Ueberauth.Strategy.FakeOidcc do
  use Ueberauth.Strategy, ignores_csrf_attack: true
  use Phoenix.Controller

  alias Ueberauth.Strategy.Helpers

  @impl Ueberauth.Strategy
  def handle_request!(conn) do
    provider = Helpers.strategy_name(conn)
    opts = Helpers.options(conn)
    initial_email = Keyword.get(opts, :initial_email, "user@test.example")
    roles = Keyword.get(opts, :roles, [])

    conn
    |> put_format(:html)
    |> put_resp_content_type("text/html")
    |> put_view(__MODULE__.View)
    |> put_layout(false)
    |> put_root_layout(false)
    |> render(:fake_login,
      provider: provider,
      initial_email: initial_email,
      roles: roles
    )
    |> halt()
  end

  @impl Ueberauth.Strategy
  def handle_callback!(conn) do
    # add a /.../callback?invalid query param to mock an invalid token for testing
    if Map.has_key?(conn.params, "invalid") or is_nil(conn.params["email"]) do
      set_errors!(conn, [error("invalid", "invalid callback")])
    else
      conn
    end
  end

  @impl Ueberauth.Strategy
  def uid(conn) do
    opts = Helpers.options(conn)
    Keyword.get(opts, :uid, "fake_uid")
  end

  @impl Ueberauth.Strategy
  def credentials(conn) do
    opts = Helpers.options(conn)
    credentials = Keyword.get(opts, :credentials, %{})
    ttl = Keyword.get(opts, :ttl, 9 * 60 * 60)

    now = System.system_time(:second)
    expiration_time = now + ttl

    %Ueberauth.Auth.Credentials{
      token: "fake_access_token",
      refresh_token: "fake_refresh_token",
      token_type: "Bearer",
      expires: true,
      expires_at: expiration_time
    }
    |> Map.merge(credentials)
  end

  @impl Ueberauth.Strategy
  def info(conn) do
    email = Map.get(conn.params, "email")

    %Ueberauth.Auth.Info{
      email: email
    }
  end

  @impl Ueberauth.Strategy
  def extra(conn) do
    opts = Helpers.options(conn)
    client_id = Keyword.get(opts, :client_id, "fake_client_id")
    userinfo = Keyword.get(opts, :userinfo, %{})

    roles = conn.params["roles"] || []

    time = System.system_time(:second)

    %Ueberauth.Auth.Extra{
      raw_info: %UeberauthOidcc.RawInfo{
        claims: %{
          "auth_time" => time,
          "iat" => time
        },
        userinfo:
          Map.merge(userinfo, %{
            "resource_access" => %{
              client_id => %{"roles" => roles}
            },
            "roles" => roles
          })
      }
    }
  end

  @impl Ueberauth.Strategy
  def handle_cleanup!(conn) do
    conn
  end

  defmodule View do
    use Phoenix.Component
    def fake_login(assigns) do
      checked = length(assigns.roles) == 1

      # TODO configurable callback url
      ~H"""
      <main class="p-4">
        <h1>Fake Keycloak/Oidcc</h1>
        <form action={"/auth/#{@provider}/callback"}>
          <div>
            <label>
              Email: <input type="email" name="email" value={@initial_email} />
            </label>
          </div>
          Roles:
          <%= for role <- @roles do %>
            <div>
              <label>
                <input type="checkbox" name="roles[]" value={role} checked={checked} />
                {role}
              </label>
            </div>
          <% end %>
          <div>
            <button
              class="mt-3 rounded-md border border-solid border-black hover:bg-gray-200 px-4 py-2 shadow"
              type="submit"
            >
              Log in
            </button>
          </div>
        </form>
      </main>
      """
    end
  end
end
