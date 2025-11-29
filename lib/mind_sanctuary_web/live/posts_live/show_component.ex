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

  # Helper function to format file sizes
  defp format_file_size(bytes) when bytes < 1_048_576, do: "#{Float.round(bytes / 1024, 1)} KB"
  defp format_file_size(bytes), do: "#{Float.round(bytes / 1_048_576, 1)} MB"

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
      <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
          <div class="mb-12">
            <div class="flex justify-between items-end">
              <div>
                <.link navigate={~p"/posts"} class="inline-flex items-center text-blue-600 hover:text-blue-700 font-semibold mb-4 transition-colors duration-200">
                  <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" />
                  Back to boards
                </.link>
                <h1 class="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
                  <span class="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-purple-600"><%= @board.name %></span>
                </h1>
                <p class="text-xl text-gray-600 max-w-2xl">
                  <%= @board.description %>
                </p>
              </div>
              <div>
                <.link navigate={~p"/posts/#{@board.id}/new"} class="group inline-flex items-center px-6 py-3 bg-gradient-to-r from-blue-600 to-purple-600 text-white font-semibold rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300">
                  <.icon name="hero-plus" class="w-5 h-5 mr-2 group-hover:rotate-90 transition-transform duration-300" />
                  New Post
                </.link>
              </div>
            </div>
          </div>

          <div class="space-y-8">
            <%= for post <- @posts do %>
              <div class="group bg-white rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 overflow-hidden">
                <div class="p-8">
                  <div class="flex justify-between items-start mb-6">
                    <div class="flex-1">
                      <h3 class="text-2xl font-bold text-gray-900 mb-3">
                        <%= post.title %>
                      </h3>
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
                        <time datetime={post.inserted_at} class="flex items-center">
                          <.icon name="hero-calendar" class="w-4 h-4 mr-1" />
                          <%= Calendar.strftime(post.inserted_at, "%B %d, %Y") %>
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

                  <div class="prose prose-gray max-w-none">
                    <p class="text-gray-700 whitespace-pre-wrap leading-relaxed">
                      <%= post.content %>
                    </p>
                  </div>

                  <%= if post.attachments && post.attachments != [] do %>
                    <div class="mt-8">
                      <h4 class="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                        <.icon name="hero-paper-clip" class="w-5 h-5 mr-2 text-gray-500" />
                        Attachments
                      </h4>
                      <div class="space-y-3">
                        <%= for attachment <- post.attachments do %>
                          <div class="group flex items-center justify-between bg-gray-50 hover:bg-gray-100 px-4 py-3 rounded-xl transition-colors duration-200">
                            <div class="flex items-center space-x-3">
                              <div class="flex-shrink-0">
                                <%= cond do %>
                                  <% String.starts_with?(attachment.content_type, "image/") -> %>
                                    <div class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                                      <.icon name="hero-photo" class="w-5 h-5 text-green-600" />
                                    </div>
                                  <% String.contains?(attachment.content_type, "pdf") -> %>
                                    <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                                      <.icon name="hero-document-text" class="w-5 h-5 text-red-600" />
                                    </div>
                                  <% true -> %>
                                    <div class="w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center">
                                      <.icon name="hero-document" class="w-5 h-5 text-gray-600" />
                                    </div>
                                <% end %>
                              </div>
                              <div>
                                <p class="text-sm font-semibold text-gray-900">
                                  <%= attachment.original_filename %>
                                </p>
                                <p class="text-xs text-gray-500">
                                  <%= format_file_size(attachment.size) %>
                                </p>
                              </div>
                            </div>
                            <div class="flex items-center space-x-2">
                              <.link
                                href={"/uploads/#{attachment.filename}"}
                                download={attachment.original_filename}
                                class="inline-flex items-center px-3 py-1.5 border border-gray-300 text-xs font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50 transition-colors duration-200"
                              >
                                <.icon name="hero-arrow-down-tray" class="w-4 h-4 mr-1" />
                                Download
                              </.link>
                            </div>
                          </div>
                        <% end %>
                      </div>
                    </div>
                  <% end %>

                  <div class="mt-8 flex justify-end">
                    <% has_supported = MindSanctuary.Posts.user_supported_post?(@current_scope.user.id, post.id) %>
                    <button
                      phx-click="support_post"
                      phx-value-post-id={post.id}
                      disabled={has_supported}
                      class={[
                        "group inline-flex items-center px-4 py-2 rounded-xl font-semibold transition-all duration-200",
                        has_supported
                          && "border border-gray-300 text-gray-500 bg-gray-100 cursor-not-allowed"
                          || "bg-gradient-to-r from-blue-600 to-purple-600 text-white shadow-lg hover:shadow-xl hover:scale-105"
                      ]}
                    >
                      <.icon name="hero-hand-thumb-up" class="w-4 h-4 mr-2 group-hover:scale-110 transition-transform duration-200" />
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
              <div class="text-center py-16">
                <div class="w-20 h-20 bg-gray-100 rounded-2xl flex items-center justify-center mx-auto mb-6">
                  <.icon name="hero-chat-bubble-left-right" class="w-10 h-10 text-gray-400" />
                </div>
                <h3 class="text-2xl font-bold text-gray-900 mb-2">No posts yet</h3>
                <p class="text-lg text-gray-600 mb-8">
                  Be the first to share in this board
                </p>
                <div>
                  <.link navigate={~p"/posts/#{@board.id}/new"} class="inline-flex items-center px-6 py-3 bg-gradient-to-r from-blue-600 to-purple-600 text-white font-semibold rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300">
                    <.icon name="hero-plus" class="w-5 h-5 mr-2" />
                    Create first post
                  </.link>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    """
  end
end
