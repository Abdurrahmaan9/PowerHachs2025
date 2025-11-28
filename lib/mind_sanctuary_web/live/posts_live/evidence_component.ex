defmodule MindSanctuaryWeb.PostsLive.EvidenceComponent do
  use MindSanctuaryWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    # Only allow admins to access this page
    if socket.assigns.current_scope.user.role != "admin" do
      {:noreply,
       socket
       |> put_flash(:error, "Access denied. Admins only.")
       |> redirect(to: ~p"/posts")}
    else
      evidence_posts = MindSanctuary.Posts.list_evidence_posts()

      socket =
        socket
        |> assign(:page_title, "Evidence Posts")
        |> assign(:evidence_posts, evidence_posts)

      {:ok, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-8">
          <div class="flex justify-between items-center">
            <div>
              <.link navigate={~p"/posts"} class="text-indigo-600 hover:text-indigo-500 text-sm font-medium mb-2 inline-block">
                ← Back to boards
              </.link>
              <h1 class="text-3xl font-bold text-gray-900">
                Evidence Posts
              </h1>
              <p class="mt-2 text-lg text-gray-600">
                Posts marked as evidence for administrative review
              </p>
            </div>
          </div>
        </div>

        <div class="space-y-6">
          <%= for post <- @evidence_posts do %>
            <div class="bg-white shadow rounded-lg border-l-4 border-red-500">
              <div class="px-4 py-5 sm:px-6">
                <div class="flex justify-between items-start">
                  <div class="flex-1">
                    <div class="flex items-center space-x-2">
                      <h3 class="text-lg font-medium text-gray-900">
                        <%= post.title %>
                      </h3>
                      <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                        Evidence
                      </span>
                      <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                        <%= String.replace(post.visibility, "_", " ") |> String.capitalize() %>
                      </span>
                    </div>
                    <div class="mt-2 text-sm text-gray-500">
                      Posted by
                      <%= if post.anonymous do %>
                        Anonymous
                      <% else %>
                        <%= post.user.username %>
                      <% end %>
                      in <%= post.board.name %>
                      · <time datetime={post.inserted_at}><%= Calendar.strftime(post.inserted_at, "%B %d, %Y at %I:%M %p") %></time>
                    </div>
                  </div>
                  <div class="ml-4 flex-shrink-0">
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                      <%= post.support_count %> supports
                    </span>
                  </div>
                </div>
                <div class="mt-4">
                  <p class="text-gray-700 whitespace-pre-wrap">
                    <%= post.content %>
                  </p>
                </div>
                <div class="mt-6 flex justify-between items-center">
                  <div class="text-sm text-gray-500">
                    Post ID: <%= post.id %> · User ID: <%= post.user_id %>
                  </div>
                  <div class="flex space-x-3">
                    <.link
                      navigate={~p"/posts/#{post.board.id}"}
                      class="inline-flex items-center px-3 py-1.5 border border-gray-300 text-xs font-medium rounded text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                    >
                      View Board
                    </.link>
                  </div>
                </div>
              </div>
            </div>
          <% end %>

          <%= if @evidence_posts == [] do %>
            <div class="text-center py-12">
              <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              <h3 class="mt-2 text-sm font-medium text-gray-900">No evidence posts</h3>
              <p class="mt-1 text-sm text-gray-500">
                No posts have been marked as evidence yet.
              </p>
            </div>
          <% end %>
        </div>
      </div>
    """
  end
end
