defmodule Ueberauth.Strategy.FakeOidccTest do
  # use FakeOidccWeb.ConnCase
  use ExUnit.Case

  import Plug.Test

  alias Ueberauth.Strategy.FakeOidcc

  describe "handle_request!" do
    test "renders login page" do
      conn =
        conn(:get, "/auth/providername")
        |> init_test_session(%{})
        |> Ueberauth.run_request(:providername, {FakeOidcc, [
          client_id: "custom-client-id",
          groups: ["group1", "group2"],
        ]})

      assert conn.resp_body =~ "group2"
    end

    test "renders login page with default config" do
      conn =
        conn(:get, "/auth/providername")
        |> init_test_session(%{})
        |> Ueberauth.run_request(:providername, {FakeOidcc, []})

      assert conn.resp_body =~ "Log in"
    end
  end

  describe "handle_callback" do
    test "works" do
      conn =
        conn(:get, "/auth/providername/callback?email=test@test.example")
        |> init_test_session(%{})
        |> Plug.Conn.fetch_query_params()
        |> Ueberauth.run_callback(:providername, {FakeOidcc, []})

      assert Map.get(conn.assigns, :ueberauth_failure) == nil
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
