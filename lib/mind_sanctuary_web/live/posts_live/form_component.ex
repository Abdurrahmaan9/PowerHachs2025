defmodule MindSanctuaryWeb.PostsLive.FormComponent do
  use MindSanctuaryWeb, :live_view

  @impl true
  def mount(%{"id" => board_id}, _session, socket) do
    board = MindSanctuary.Posts.get_board!(board_id)

    socket =
      socket
      |> assign(:page_title, "New Post")
      |> assign(:board, board)
      |> assign(:form, to_form(%{
        "title" => "",
        "content" => "",
        "anonymous" => true,
        "visibility" => "all",
        "is_evidence" => false
      }))

    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"post" => post_params}, socket) do
    IO.inspect("Save event triggered!")
    IO.inspect(post_params, label: "Post params received")
    IO.inspect(socket.assigns.current_scope, label: "Current scope")

    post_params = Map.merge(post_params, %{
      "board_id" => socket.assigns.board.id,
      "user_id" => socket.assigns.current_scope.user.id
    })

    IO.inspect(post_params, label: "Final post params")

    case MindSanctuary.Posts.create_post(post_params) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully.")
         |> push_navigate(to: ~p"/posts/#{socket.assigns.board.id}")}

      {:error, changeset} ->
        IO.inspect(changeset, label: "Changeset errors")
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event(event, params, socket) do
    IO.inspect("Unexpected event: #{event}")
    IO.inspect(params, label: "Event params")
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="mb-8">
          <.link navigate={~p"/posts/#{@board.id}"} class="text-indigo-600 hover:text-indigo-500 text-sm font-medium mb-2 inline-block">
            ← Back to <%= @board.name %>
          </.link>
          <h1 class="text-3xl font-bold text-gray-900">
            Create New Post
          </h1>
          <p class="mt-2 text-lg text-gray-600">
            Share your thoughts in the <%= @board.name %> board
          </p>
        </div>

        <div class="bg-white shadow rounded-lg">
          <div class="px-4 py-5 sm:p-6">
            <.form for={@form} phx-submit="save" class="space-y-6">
              <div>
                <.input
                  field={@form[:title]}
                  type="text"
                  label="Title"
                  placeholder="Give your post a descriptive title"
                  required
                  name="post[title]"
                />
              </div>

              <div>
                <.input
                  field={@form[:content]}
                  type="textarea"
                  label="Content"
                  placeholder="Share your thoughts, experiences, or questions..."
                  rows="8"
                  required
                  name="post[content]"
                />
              </div>

              <div>
                <div class="flex items-center">
                  <.input
                    field={@form[:anonymous]}
                    type="checkbox"
                    label="Post anonymously"
                    value="true"
                    class="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                    name="post[anonymous]"
                  />
                </div>
                <p class="mt-1 text-sm text-gray-500">
                  Your identity will be hidden from other users
                </p>
              </div>

              <div>
                <.input
                  field={@form[:visibility]}
                  type="select"
                  label="Who can see this post?"
                  name="post[visibility]"
                  options={[
                    {"All users", "all"},
                    {"Admins and volunteers only", "admins_volunteers"},
                    {"Admins only", "admins"}
                  ]}
                />
                <p class="mt-1 text-sm text-gray-500">
                  Choose who can view this post based on their role
                </p>
              </div>

              <div>
                <div class="flex items-center">
                  <.input
                    field={@form[:is_evidence]}
                    type="checkbox"
                    label="Mark as evidence (admin only)"
                    value="true"
                    class="h-4 w-4 text-red-600 focus:ring-red-500 border-gray-300 rounded"
                    name="post[is_evidence]"
                  />
                </div>
                <p class="mt-1 text-sm text-gray-500">
                  Evidence posts are only visible to administrators in the evidence table
                </p>
              </div>

              <div class="flex justify-end space-x-3">
                <.link
                  navigate={~p"/posts/#{@board.id}"}
                  class="bg-gray-300 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-400 transition-colors duration-200"
                >
                  Cancel
                </.link>
                <button
                  type="submit"
                  class="bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 transition-colors duration-200"
                >
                  Create Post
                </button>
              </div>
            </.form>
          </div>
        </div>

        <div class="mt-8 bg-blue-50 border border-blue-200 rounded-md p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-blue-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-blue-800">
                Community Guidelines
              </h3>
              <div class="mt-2 text-sm text-blue-700">
                <ul class="list-disc list-inside space-y-1">
                  <li>Be respectful and supportive of others</li>
                  <li>Share experiences that may help others</li>
                  <li>Protect your privacy and avoid sharing personal identifying information</li>
                  <li>Remember that this is a safe space for healing and support</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    """
  end
end
