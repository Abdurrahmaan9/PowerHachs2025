defmodule MindSanctuaryWeb.AdminLive.SeedData do
  use MindSanctuaryWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("seed_boards", _params, socket) do
    case seed_boards() do
      {:ok, results} ->
        {:noreply,
         socket
         |> put_flash(:info, "Successfully created #{length(results)} boards")
         |> push_patch(to: "/admin/seed_data")}
    end
  end

  defp seed_boards() do
    alias MindSanctuary.Repo
    alias MindSanctuary.Posts.Board

    boards = [
      %{
        name: "Domestic Violence Support",
        description: "A safe space to share experiences and find support for those affected by domestic violence",
        category: "domestic_violence",
        color: "red"
      },
      %{
        name: "Sexual Assault Survivors",
        description: "Support and healing for survivors of sexual assault in a confidential environment",
        category: "sexual_assault",
        color: "purple"
      },
      %{
        name: "Harassment & Bullying",
        description: "Discuss experiences with harassment and bullying, share coping strategies",
        category: "harassment",
        color: "yellow"
      },
      %{
        name: "Stalking Awareness",
        description: "Resources and support for those dealing with stalking situations",
        category: "stalking",
        color: "indigo"
      },
      %{
        name: "Emotional Abuse Recovery",
        description: "Healing from emotional and psychological abuse in relationships",
        category: "emotional_abuse",
        color: "pink"
      },
      %{
        name: "Financial Abuse Support",
        description: "Addressing financial control and economic abuse in relationships",
        category: "financial_abuse",
        color: "green"
      },
      %{
        name: "Resources & Hotlines",
        description: "Share and discover emergency resources, hotlines, and support services",
        category: "support_resources",
        color: "blue"
      }
    ]

    results = Enum.map(boards, fn board_attrs ->
      case %Board{}
           |> Board.changeset(board_attrs)
           |> Repo.insert() do
        {:ok, board} -> {:ok, board.name}
        {:error, _changeset} -> {:error, board_attrs.name}
      end
    end)

    {:ok, results}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">Admin - Seed Data</h1>

      <div class="bg-white shadow rounded-lg p-6">
        <h2 class="text-xl font-semibold mb-4">Seed Support Boards</h2>
        <p class="text-gray-600 mb-6">
          Click the button below to create the support boards that are normally created during database seeding.
          This will create the following boards:
        </p>

        <ul class="list-disc list-inside text-gray-700 mb-6 space-y-1">
          <li>Domestic Violence Support</li>
          <li>Sexual Assault Survivors</li>
          <li>Harassment & Bullying</li>
          <li>Stalking Awareness</li>
          <li>Emotional Abuse Recovery</li>
          <li>Financial Abuse Support</li>
          <li>Resources & Hotlines</li>
        </ul>

        <.button
          phx-click="seed_boards"
          class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
        >
          Seed Support Boards
        </.button>
      </div>
    </div>
    """
  end
end
