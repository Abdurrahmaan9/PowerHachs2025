defmodule MindSanctuaryWeb.MoodLiveTest do
  use MindSanctuaryWeb.ConnCase

  import Phoenix.LiveViewTest
  import MindSanctuary.AccountsFixtures

  alias MindSanctuary.Mood

  @create_attrs %{
    mood: "happy",
    journal_entry: "Had a great day today!",
    energy_level: 8,
    stress_level: 3,
    sleep_hours: 7.5
  }
  @invalid_attrs %{mood: nil}

  setup :register_and_log_in_user

  describe "Index" do
    test "lists all mood entries", %{conn: conn, user: user} do
      {:ok, _entry} = Mood.create_entry(user, @create_attrs)
      {:ok, _view, html} = live(conn, ~p"/mood")
      assert html =~ "Mood Tracker"
      assert html =~ "Had a great day today!"
    end

    test "saves new entry", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/mood")

      assert view
             |> form("form", entry: @create_attrs)
             |> render_submit() =~ "Mood entry created successfully"
    end

    test "validates entry data", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/mood")

      assert view
             |> form("form", entry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"
    end

    test "deletes entry", %{conn: conn, user: user} do
      {:ok, entry} = Mood.create_entry(user, @create_attrs)
      {:ok, view, _html} = live(conn, ~p"/mood")

      assert view |> element("button", "Delete") |> render_click()
      refute has_element?(view, "#entry-#{entry.id}")
    end
  end
end
