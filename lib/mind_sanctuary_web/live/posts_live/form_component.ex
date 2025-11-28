defmodule MindSanctuaryWeb.PostsLive.FormComponent do
  use MindSanctuaryWeb, :live_view

  # Helper function to format file sizes
  defp format_file_size(bytes) when bytes < 1_048_576, do: "#{Float.round(bytes / 1024, 1)} KB"
  defp format_file_size(bytes), do: "#{Float.round(bytes / 1_048_576, 1)} MB"

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
     |> allow_upload(:file_url, accept: ~w(.pdf .png .jpeg .mp3 .mp4), max_entries: 1)

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

    # Upload files first, then create post with attachment URLs (same pattern as resources)
    IO.inspect("About to upload attachments...")
    IO.inspect(socket.assigns.uploads.attachments.entries, label: "Upload entries before consumption")

    attachment_urls =
      case MindSanctuary.Posts.upload_attachments(socket, "/uploads") do
        {:error, e} ->
          IO.inspect(e, label: "Upload error")
          []
        urls when is_list(urls) ->
          IO.inspect(urls, label: "Upload URLs returned")
          urls
        other ->
          IO.inspect(other, label: "Unexpected upload result")
          []
      end

    IO.inspect(attachment_urls, label: "Uploaded attachment URLs")

    case MindSanctuary.Posts.create_post(post_params) do
      {:ok, post} ->
        # Create attachment records for each uploaded file
        Enum.each(attachment_urls, fn url ->
          MindSanctuary.Posts.create_attachment(%{
            "post_id" => post.id,
            "filename" => Path.basename(url),
            "path" => url,
            "original_filename" => Path.basename(url)
          })
        end)

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
  def handle_event("validate", %{"post" => post_params}, socket) do
    {:noreply, assign(socket, :form, to_form(%{post_params | "is_evidence" => false}))}
  end

  @impl true
  def handle_event("add-upload", %{"upload" => upload}, socket) do
    IO.inspect(upload, label: "File upload received")
    {:noreply, assign(socket, :uploaded_files, [upload | socket.assigns.uploaded_files || []])}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :attachments, ref)}
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

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  Attachments
                </label>
                <div
                  phx-drop-target={@uploads.attachments.ref}
                  class="border-2 border-gray-300 border-dashed rounded-lg p-6 text-center hover:border-gray-400 transition-colors"
                >
                  <svg class="mx-auto h-12 w-12 text-gray-400" stroke="currentColor" fill="none" viewBox="0 0 48 48">
                    <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
                  </svg>
                  <div class="mt-4">
                    <label for="file-upload" class="cursor-pointer">
                      <span class="mt-2 block text-sm font-medium text-gray-900">
                        Click to upload or drag and drop
                      </span>
                      <span class="mt-1 block text-xs text-gray-500">
                        PNG, JPG, GIF, PDF up to 10MB each
                      </span>
                    </label>
                    <.live_file_input
                      upload={@uploads.attachments}
                      class="sr-only"
                      id="file-upload"
                    />
                  </div>
                </div>

                <%= for entry <- @uploads.attachments.entries do %>
                  <div class="mt-4">
                    <div class="flex items-center justify-between text-sm text-gray-600 bg-gray-50 px-3 py-2 rounded">
                      <span><%= entry.client_name %></span>
                      <div class="flex items-center space-x-2">
                        <%= if entry.progress > 0 do %>
                          <span class="text-xs text-gray-500"><%= entry.progress %>%</span>
                        <% end %>
                        <button
                          type="button"
                          phx-click="cancel-upload"
                          phx-value-ref={entry.ref}
                          class="text-red-500 hover:text-red-700"
                        >
                          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                          </svg>
                        </button>
                      </div>
                    </div>
                    <%= if entry.progress > 0 do %>
                      <div class="mt-1 w-full bg-gray-200 rounded-full h-1">
                        <div class="bg-blue-600 h-1 rounded-full transition-all duration-300" style={"width: #{entry.progress}%"}></div>
                      </div>
                    <% end %>
                  </div>
                <% end %>

                <%= for err <- @uploads.attachments.errors do %>
                  <div class="mt-2 text-sm text-red-600">
                    <%= err.message %>
                  </div>
                <% end %>
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
