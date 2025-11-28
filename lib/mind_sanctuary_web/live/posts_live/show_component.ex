defmodule MindSanctuaryWeb.PostsLive.ShowComponent do
  use MindSanctuaryWeb, :live_view

  @impl true
  def mount(%{"id" => board_id}, _session, socket) do
    board = MindSanctuary.Posts.get_board!(board_id)
    user_role = socket.assigns.current_scope.user.role
    posts = MindSanctuary.Posts.list_posts_for_board(board_id, user_role)

    socket =
      socket
      |> assign(:page_title, board.name)
      |> assign(:board, board)
      |> assign(:posts, posts)

    {:ok, socket}
  end

  @impl true
  def handle_event("support_post", %{"post-id" => post_id}, socket) do
    IO.inspect("Support post triggered for post: #{post_id}")

    user_id = socket.assigns.current_scope.user.id
    user_role = socket.assigns.current_scope.user.role

    case MindSanctuary.Posts.support_post(user_id, post_id) do
      {:ok, _support} ->
        posts = MindSanctuary.Posts.list_posts_for_board(socket.assigns.board.id, user_role)
        {:noreply,
         socket
         |> assign(:posts, posts)
         |> put_flash(:info, "Post supported successfully!")}

      {:error, changeset} ->
        IO.inspect(changeset, label: "Support error")
        {:noreply,
         socket
         |> put_flash(:error, "You have already supported this post")}
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
                <%= @board.name %>
              </h1>
              <p class="mt-2 text-lg text-gray-600">
                <%= @board.description %>
              </p>
            </div>
            <div>
              <.link navigate={~p"/posts/#{@board.id}/new"} class="bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 transition-colors duration-200">
                New Post
              </.link>
            </div>
          </div>
        </div>

        <div class="space-y-6">
          <%= for post <- @posts do %>
            <div class="bg-white shadow rounded-lg">
              <div class="px-4 py-5 sm:px-6">
                <div class="flex justify-between items-start">
                  <div class="flex-1">
                    <h3 class="text-lg font-medium text-gray-900">
                      <%= post.title %>
                    </h3>
                    <div class="mt-2 text-sm text-gray-500">
                      Posted by
                      <%= if post.anonymous do %>
                        Anonymous
                      <% else %>
                        <%= post.user.username %>
                      <% end %>
                      · <time datetime={post.inserted_at}><%= Calendar.strftime(post.inserted_at, "%B %d, %Y") %></time>
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
                <div class="mt-6 flex justify-end">
                  <% has_supported = MindSanctuary.Posts.user_supported_post?(@current_scope.user.id, post.id) %>
                  <button
                    phx-click="support_post"
                    phx-value-post-id={post.id}
                    disabled={has_supported}
                    class={[
                      "inline-flex items-center px-3 py-1.5 border text-xs font-medium rounded transition-colors duration-200",
                      has_supported
                        && "border-gray-300 text-gray-500 bg-gray-100 cursor-not-allowed"
                        || "border-transparent text-indigo-700 bg-indigo-100 hover:bg-indigo-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                    ]}
                  >
                    <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                      <path d="M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43a2 2 0 001.106 1.79l.05.025A4 4 0 008.943 18h5.416a2 2 0 001.962-1.608l1.2-6A2 2 0 0015.56 8H12V4a2 2 0 00-2-2 1 1 0 00-1 1v.667a4 4 0 01-.8 2.4L6.8 7.933a4 4 0 00-.8 2.4z" />
                    </svg>
                    <%= if has_supported do %>
                      Supported
                    <% else %>
                      Support
                    <% end %>
                  </button>
                </div>
              </div>
            </div>
          <% end %>

          <%= if @posts == [] do %>
            <div class="text-center py-12">
              <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8h2a2 2 0 012 2v6a2 2 0 01-2 2h-2v4l-4-4H9a1.994 1.994 0 01-1.414-.586m0 0L11 14h4a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2v4l.586-.586z" />
              </svg>
              <h3 class="mt-2 text-sm font-medium text-gray-900">No posts yet</h3>
              <p class="mt-1 text-sm text-gray-500">
                Be the first to share in this board
              </p>
              <div class="mt-6">
                <.link navigate={~p"/posts/#{@board.id}/new"} class="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                  Create first post
                </.link>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    """
  end
end
