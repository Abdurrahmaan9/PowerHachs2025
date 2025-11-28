defmodule MindSanctuaryWeb.PostsLive.Index do
  use MindSanctuaryWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    boards = MindSanctuary.Posts.list_boards()

    socket =
      socket
      |> assign(:page_title, "Support Boards")
      |> assign(:boards, boards)

    {:ok, socket}
  end
end
