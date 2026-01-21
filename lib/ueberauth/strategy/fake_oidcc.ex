defmodule Ueberauth.Strategy.FakeOidcc do
  use Ueberauth.Strategy, ignores_csrf_attack: true
  use Phoenix.Controller

  alias Ueberauth.Strategy.Helpers

  @impl Ueberauth.Strategy
  def handle_request!(conn) do
    opts = Helpers.options(conn)
    groups = Keyword.get(opts, :groups, [])

    conn
    |> put_format(:html)
    |> put_resp_content_type("text/html")
    |> put_view(__MODULE__.View)
    |> render(:fake_login, groups: groups, layout: false)
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
  def uid(_conn) do
    "fake_uid"
  end

  @impl Ueberauth.Strategy
  def credentials(_conn) do
    # TODO make configurable?
    nine_hours_in_seconds = 9 * 60 * 60
    expiration_time = System.system_time(:second) + nine_hours_in_seconds

    %Ueberauth.Auth.Credentials{
      token: "fake_access_token",
      refresh_token: "fake_refresh_token",
      expires: true,
      expires_at: expiration_time
    }
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

    groups = conn.params["groups"] || []

    %Ueberauth.Auth.Extra{
      raw_info: %UeberauthOidcc.RawInfo{
        userinfo: %{
          "resource_access" => %{
            client_id => %{"roles" => groups}
          }
        }
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
              Email: <input type="email" name="email" value="user@example.com" />
            </label>
          </div>
          <%= for group <- @groups do %>
            <div>
              <label>
                <input type="checkbox" name="groups[]" value={group} />
                {group} group
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
