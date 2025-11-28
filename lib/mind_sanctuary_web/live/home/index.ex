defmodule MindSanctuaryWeb.HomeLive.Index do
  use MindSanctuaryWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
      {:ok, socket}
    end
end
