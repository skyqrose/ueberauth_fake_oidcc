defmodule Ueberauth.Strategy.FakeOidccTest do
  # use FakeOidccWeb.ConnCase
  use ExUnit.Case

  import Plug.Test

  alias Ueberauth.Strategy.FakeOidcc

  describe "handle_request!" do
    test "renders login page with empty config" do
      conn =
        conn(:get, "/auth/providername")
        |> init_test_session(%{})
        |> Ueberauth.run_request(:providername, {FakeOidcc, []})

      assert conn.resp_body =~ "Log in"
    end

    test "renders login page with full config" do
      conn =
        conn(:get, "/auth/providername")
        |> init_test_session(%{})
        |> Ueberauth.run_request(
          :providername,
          {FakeOidcc,
           [
             initial_email: "initial@email.example",
             roles: ["role1", "role2"]
           ]}
        )

      assert conn.resp_body =~ "initial@email.example"
      assert conn.resp_body =~ "role2"
    end
  end

  describe "handle_callback" do
    # also covers uid, credentials, info, extra
    test "works with default config" do
      conn =
        conn(:get, "/auth/providername/callback?email=test@test.example")
        |> init_test_session(%{})
        |> Plug.Conn.fetch_query_params()
        |> Ueberauth.run_callback(:providername, {FakeOidcc, []})

      assert Map.get(conn.assigns, :ueberauth_failure) == nil

      assert %Ueberauth.Auth{
               uid: "fake_uid",
               provider: :providername,
               info: %Ueberauth.Auth.Info{
                 email: "test@test.example"
               },
               credentials: %Ueberauth.Auth.Credentials{
                 token: "fake_access_token",
                 refresh_token: "fake_refresh_token"
               },
               extra: %Ueberauth.Auth.Extra{
                 # "roles" => [],
                 # "resource_access" => %{
                 #   "fake_client_id" => %{"roles" => []}
                 # },
               }
             } = conn.assigns.ueberauth_auth
    end

    test "is invalid without email" do
      conn =
        conn(:get, "/auth/providername/callback")
        |> init_test_session(%{})
        |> Plug.Conn.fetch_query_params()
        |> Ueberauth.run_callback(:providername, {FakeOidcc, []})

      assert Map.get(conn.assigns, :ueberauth_failure) != nil
    end

    test "is invalid if given invalid param" do
      conn =
        conn(:get, "/auth/providername/callback?email=test@test.example&invalid")
        |> init_test_session(%{})
        |> Plug.Conn.fetch_query_params()
        |> Ueberauth.run_callback(:providername, {FakeOidcc, []})

      assert Map.get(conn.assigns, :ueberauth_failure) != nil
    end
  end
end
