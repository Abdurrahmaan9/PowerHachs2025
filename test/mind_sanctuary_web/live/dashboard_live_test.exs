defmodule MindSanctuaryWeb.DashboardLiveTest do
  use MindSanctuaryWeb.ConnCase

  import Phoenix.LiveViewTest
  import MindSanctuary.AccountsFixtures

  setup :register_and_log_in_user

  describe "Dashboard page" do
    test "renders dashboard with user information", %{conn: conn, user: user} do
      {:ok, view, html} = live(conn, ~p"/dashboard")

      assert html =~ "Welcome"
      assert html =~ user.email
      assert html =~ "Mood Tracker"
      assert html =~ "Resource Hub"
      assert html =~ "Anonymous Peer Support"
      assert html =~ "Events & Workshops"
      assert html =~ "Recent Activity"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      conn = log_out_user(conn)
      assert {:error, redirect} = live(conn, ~p"/dashboard")
      assert redirect.to == ~p"/users/log-in"
    end
  end
end
