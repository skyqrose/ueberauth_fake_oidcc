defmodule Ueberauth.Strategy.FakeOidccTest do
  # use FakeOidccWeb.ConnCase
  use ExUnit.Case

  # import Plug.Conn
  # import Phoenix.ConnTest

  alias Ueberauth.Strategy.FakeOidcc

  defmacro config(opts) do
    quote do
      Application.put_env(:ueberauth, Ueberauth,
        providers: [
          providername: {Ueberauth.Strategy.FakeOidcc, unquote(opts)}
        ]
      )

      on_exit(fn ->
        Application.delete_env(:ueberauth, Ueberauth)
      end)
    end
  end

  describe "handle_request!" do
    test "renders login page" do
      config(groups: ["group1", "group2"])
      conn = Phoenix.ConnTest.build_conn()

      conn =
        conn
        |> FakeOidcc.handle_request!()

      assert conn.resp_body =~ "group2"
    end

    test "renders login page with no groups" do
      config([])
      conn = Phoenix.ConnTest.build_conn()

      conn =
        conn
        |> FakeOidcc.handle_request!()

      assert conn.resp_body =~ "Log in"
    end
  end
end
