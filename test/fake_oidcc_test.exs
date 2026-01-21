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
end
