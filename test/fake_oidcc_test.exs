defmodule Ueberauth.Strategy.FakeOidccTest do
  # use FakeOidccWeb.ConnCase
  use ExUnit.Case

  import Plug.Test

  alias Phoenix.ConnTest
  alias Ueberauth.Strategy.FakeOidcc

  describe "handle_request!" do
    test "renders login page" do
      conn =
        conn(:get, "/auth/providername")
        |> init_test_session(%{})
        |> Ueberauth.run_request(:providername, {FakeOidcc, [
          client_id: "custom-client-id",
          roles: ["role1", "role2"],
        ]})

      assert conn.resp_body =~ "role2"
    end

    test "renders login page with default config" do
      conn =
        conn(:get, "/auth/providername")
        |> init_test_session(%{})
        |> Ueberauth.run_request(:providername, {FakeOidcc, FakeOidcc.default_options()})

      assert conn.resp_body =~ "Log in"
    end

    test "renders login page with empty config" do
      conn =
        conn(:get, "/auth/providername")
        |> init_test_session(%{})
        |> Ueberauth.run_request(:providername, {FakeOidcc, []})

      assert conn.resp_body =~ "Log in"
    end
  end

  describe "handle_callback" do
    # also covers uid, credentials, info, extra
    test "works" do
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
          refresh_token: "fake_refresh_token",
          # TODO assert expires here?
        },
        extra: %Ueberauth.Auth.Extra{
          # TODO roles?
          # under client_id
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

  describe "handle_cleanup!" do
    test "doesn't crash" do
      # doesn't do anything, but Ueberauth calls it and it's not covered above
      # so verify it doesn't crash I guess
      conn = Phoenix.ConnTest.build_conn()
      assert FakeOidcc.handle_cleanup!(conn) == conn
    end
  end
end
