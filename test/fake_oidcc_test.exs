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
             callback_path: "/callbackpath",
             initial_email: "initial@email.example",
             roles: ["role1", "role2"]
           ]}
        )

      assert conn.resp_body =~ "/callbackpath"
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
                 raw_info: %UeberauthOidcc.RawInfo{
                   claims: %{
                     "auth_time" => auth_time,
                     "iat" => auth_time
                   },
                   userinfo: %{
                     "roles" => [],
                     "resource_access" => %{
                       "fake_client_id" => %{"roles" => []}
                     }
                   }
                 }
               }
             } = conn.assigns.ueberauth_auth
    end

    test "works with full config" do
      conn =
        conn(
          :get,
          "/auth/providername/callback?email=test@test.example&roles[]=role1&roles[]=role2"
        )
        |> init_test_session(%{})
        |> Plug.Conn.fetch_query_params()
        |> Ueberauth.run_callback(
          :providername,
          {FakeOidcc,
           [
             client_id: "custom_client_id",
             credentials: %{other: %{custom_field: "value1"}},
             info: %{email: "overwritten", nickname: "nick"},
             ttl: 10,
             uid: "custom_uid",
             userinfo: %{"custom_field" => "value2"}
           ]}
        )

      assert Map.get(conn.assigns, :ueberauth_failure) == nil

      assert %Ueberauth.Auth{
               uid: "custom_uid",
               provider: :providername,
               info: %Ueberauth.Auth.Info{
                 email: "test@test.example",
                 nickname: "nick"
               },
               credentials: %Ueberauth.Auth.Credentials{
                 token: "fake_access_token",
                 refresh_token: "fake_refresh_token",
                 expires_at: expires_at,
                 other: %{custom_field: "value1"}
               },
               extra: %Ueberauth.Auth.Extra{
                 raw_info: %UeberauthOidcc.RawInfo{
                   claims: %{
                     "auth_time" => auth_time,
                     "iat" => auth_time
                   },
                   userinfo: %{
                     "custom_field" => "value2",
                     "roles" => ["role1", "role2"],
                     "resource_access" => %{
                       "custom_client_id" => %{"roles" => ["role1", "role2"]}
                     }
                   }
                 }
               }
             } = conn.assigns.ueberauth_auth

      # allow wiggle room on ttl calculation to avoid flaky test
      ttl = expires_at - auth_time
      assert ttl >= 9 and ttl <= 11
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
