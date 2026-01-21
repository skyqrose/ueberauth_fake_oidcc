defmodule Ueberauth.Strategy.FakeOidcc do
  use Ueberauth.Strategy, ignores_csrf_attack: true
  use Phoenix.Controller

  alias Ueberauth.Strategy.Helpers

  @impl Ueberauth.Strategy
  def handle_request!(conn) do
    opts = Helpers.options(conn)
    initial_email = Keyword.get(opts, :initial_email, "user@test.example")
    roles = Keyword.get(opts, :roles, [])

    conn
    |> put_format(:html)
    |> put_resp_content_type("text/html")
    |> put_view(__MODULE__.View)
    |> render(:fake_login,
      initial_email: initial_email,
      roles: roles,
      layout: false
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

    # TODO make configurable?
    nine_hours_in_seconds = 9 * 60 * 60
    expiration_time = System.system_time(:second) + nine_hours_in_seconds

    %Ueberauth.Auth.Credentials{
      token: "fake_access_token",
      refresh_token: "fake_refresh_token",
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

  # control all info coming out at compile time (only email at runtime?)
  # and selected roles
  # could add more form fields, but don't want to unless i actually have to

  # uid: sub
  # credentials: token, refresh -token, expires, expires_at
  # expires at: glorbit: 9hr. mycharlie: check get_session(:expiration_datetime) first, then 9h
  # mycharlie sets other: idtoken for its own use

  # info: email
  # extra: client_id, roles

  @impl Ueberauth.Strategy
  def extra(conn) do
    opts = Helpers.options(conn)
    client_id = Keyword.get(opts, :client_id, "fake_client_id")
    userinfo = Keyword.get(opts, :userinfo, %{})

    roles = conn.params["roles"] || []

    %Ueberauth.Auth.Extra{
      raw_info: %UeberauthOidcc.RawInfo{
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
    # TODO options for failure modes: redirect to invalid?

    def fake_login(assigns) do
      ~H"""
      <main class="p-4">
        <h1>Fake Keycloak/Oidcc</h1>
        <!-- TODO configurable callback url -->
        <form action="/auth/keycloak/callback">
          <div>
            <label>
              <!-- TODO configurable default email -->
              Email: <input type="email" name="email" value={@initial_email} />
            </label>
          </div>
          <%= for role <- @roles do %>
            <div>
              <label>
                <input type="checkbox" name="roles[]" value={role} />
                {role} role
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
