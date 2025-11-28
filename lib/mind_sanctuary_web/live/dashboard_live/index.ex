defmodule MindSanctuaryWeb.DashboardLive.Index do
  use MindSanctuaryWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Dashboard")

    if connected?(socket) do
      resp = Req.get!(url: "https://thequoteshub.com/api")

      quote =
        if is_map(resp.body) and resp.body != %{} do
          %{
            text: Map.get(resp.body, "text"),
            author: Map.get(resp.body, "author"),
            tags: Map.get(resp.body, "tags")
          }
        else
          nil
        end

      {:ok, assign(socket, quote: quote)}
    else
      {:ok, socket |> assign(:quote, nil)}
    end
  end
end
