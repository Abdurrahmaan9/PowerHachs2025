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
      <div class="min-h-screen bg-gradient-to-br from-blue-100 via-white to-purple-100">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
          <div class="mb-12">
            <div class="flex justify-between items-end">
              <div>
                <.link navigate={~p"/posts"} class="inline-flex items-center text-blue-600 hover:text-blue-700 font-semibold mb-4 transition-colors duration-200">
                  <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" />
                  Back to boards
                </.link>
                <h1 class="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
                  <span class="text-transparent bg-clip-text bg-gradient-to-r from-red-600 to-orange-600">Evidence Posts</span>
                </h1>
                <p class="text-xl text-gray-600 max-w-2xl">
                  Posts marked as evidence for administrative review
                </p>
              </div>
            </div>
          </div>

          <div class="space-y-8">
            <%= for post <- @evidence_posts do %>
              <div class="group bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 overflow-hidden border-l-4 border-red-500">
                <div class="p-8">
                  <div class="flex justify-between items-start mb-6">
                    <div class="flex-1">
                      <div class="flex items-center space-x-3 mb-3">
                        <h3 class="text-2xl font-bold text-gray-900">
                          <%= post.title %>
                        </h3>
                        <span class="inline-flex items-center px-3 py-1.5 rounded-full text-sm font-semibold bg-gradient-to-r from-red-100 to-orange-100 text-red-800">
                          <.icon name="hero-exclamation-triangle" class="w-4 h-4 mr-1" />
                          Evidence
                        </span>
                        <span class="inline-flex items-center px-3 py-1.5 rounded-full text-sm font-medium bg-gray-100 text-gray-800">
                          <%= String.replace(post.visibility, "_", " ") |> String.capitalize() %>
                        </span>
                      </div>
                      <div class="flex items-center space-x-4 text-sm text-gray-500">
                        <div class="flex items-center space-x-2">
                          <div class="w-8 h-8 bg-gradient-to-br from-blue-100 to-purple-100 rounded-full flex items-center justify-center">
                            <.icon name="hero-user" class="w-4 h-4 text-blue-600" />
                          </div>
                          <span>
                            <%= if post.anonymous do %>
                              Anonymous
                            <% else %>
                              <%= post.user.username %>
                            <% end %>
                          </span>
                        </div>
                        <span class="text-gray-300">•</span>
                        <span class="flex items-center">
                          <.icon name="hero-chat-bubble-left-right" class="w-4 h-4 mr-1" />
                          <%= post.board.name %>
                        </span>
                        <span class="text-gray-300">•</span>
                        <time datetime={post.inserted_at} class="flex items-center">
                          <.icon name="hero-calendar" class="w-4 h-4 mr-1" />
                          <%= Calendar.strftime(post.inserted_at, "%B %d, %Y at %I:%M %p") %>
                        </time>
                      </div>
                    </div>
                    <div class="ml-4 flex-shrink-0">
                      <span class="inline-flex items-center px-3 py-1.5 rounded-full text-sm font-semibold bg-gradient-to-r from-green-100 to-emerald-100 text-green-800">
                        <.icon name="hero-heart" class="w-4 h-4 mr-1" />
                        <%= post.support_count %> supports
                      </span>
                    </div>
                  </div>

                  <div class="prose prose-gray max-w-none mb-8">
                    <p class="text-gray-700 whitespace-pre-wrap leading-relaxed">
                      <%= post.content %>
                    </p>
                  </div>

                  <div class="flex justify-between items-center pt-6 border-t border-gray-100">
                    <div class="flex items-center space-x-6 text-sm text-gray-500">
                      <div class="flex items-center space-x-2">
                        <.icon name="hero-fingerprint" class="w-4 h-4" />
                        <span>Post ID: <%= post.id %></span>
                      </div>
                      <div class="flex items-center space-x-2">
                        <.icon name="hero-user-circle" class="w-4 h-4" />
                        <span>User ID: <%= post.user_id %></span>
                      </div>
                    </div>
                    <div class="flex space-x-3">
                      <.link
                        navigate={~p"/posts/#{post.board.id}"}
                        class="group inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50 transition-colors duration-200"
                      >
                        <.icon name="hero-eye" class="w-4 h-4 mr-2 group-hover:scale-110 transition-transform duration-200" />
                        View Board
                      </.link>
                    </div>
                  </div>
                </div>
              </div>
            <% end %>

            <%= if @evidence_posts == [] do %>
              <div class="text-center py-16">
                <div class="w-20 h-20 bg-gray-100 rounded-2xl flex items-center justify-center mx-auto mb-6">
                  <.icon name="hero-shield-check" class="w-10 h-10 text-gray-400" />
                </div>
                <h3 class="text-2xl font-bold text-gray-900 mb-2">No evidence posts</h3>
                <p class="text-lg text-gray-600">
                  No posts have been marked as evidence yet.
                </p>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    """
  end
end
