defmodule MindSanctuaryWeb.ResourcesLive.Index do
  use MindSanctuaryWeb, :live_view
  alias MindSanctuary.Resources
  alias MindSanctuary.Resources.Resource

  @impl true
  def mount(_params, _session, socket) do
    resources = Resources.list_resources(socket.assigns.current_scope)

    featured_resources =
      resources
      |> Enum.filter(& &1.is_featured)

    form = to_form(%{"q" => ""})

    {:ok,
     socket
     |> assign(page_title: "Resource Hub")
     |> assign(form: form, resources: resources, filtered_resources: resources)
     |> assign(:changeset, to_form(Resources.change_resource(%Resource{})))
     |> assign(:current_filter, "all")
     |> assign(:resources, resources)
     |> assign(:resource, %Resource{})
     |> assign(:featured_resources, featured_resources)
     |> assign(:show_form, false)
     |> assign(:editing_resource, false)
     |> assign(show_form: false)
     |> allow_upload(:file_url, accept: ~w(.pdf .png .jpeg .mp3 .mp4), max_entries: 1)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply,
     socket
     |> assign(:params, params)}
  end

  @impl true
  def handle_event("search", %{"q" => q}, socket) do
    q_down = String.downcase(q || "")

    filtered =
      socket.assigns.resources
      |> Enum.filter(fn r ->
        String.contains?(String.downcase(r.title), q_down) or
          String.contains?(String.downcase(r.description), q_down) or
          Enum.any?(r.tags, fn t -> String.contains?(String.downcase(t), q_down) end)
      end)

    {:noreply, assign(socket, filtered_resources: filtered, form: to_form(%{"q" => q}))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    resource = Resources.get_resource!(id)
    {:ok, _} = Resources.delete_resource(resource)

    resources = Resources.list_resources(socket.assigns.current_scope)

    featured_resources =
      resources
      |> Enum.filter(fn
        r -> r.is_featured == true
      end)

    {:noreply,
     socket
     |> assign(
       resources: resources,
       filtered_resources: resources,
       featured_resources: featured_resources
     )
     |> put_flash(:info, "Resource deleted successfully")}
  end

  @impl true
  def handle_event("show_resource_form", _params, socket) do
    {:noreply, assign(socket, :show_form, true)}
  end

  @impl true
  def handle_event("hide_form", _params, socket) do
    {:noreply, assign(socket, :show_form, false)}
  end

  @impl true
  def handle_event("validate", %{"resource" => params}, socket) do
    changeset = Resources.change_resource(socket.assigns.resource, params)

    {:noreply,
     socket
     |> assign(changeset: to_form(Map.put(changeset, :action, :validate)))}
  end

  @impl true
  def handle_event("save", %{"resource" => resource_params}, socket) do
    save_resource(socket, socket.assigns.live_action, resource_params)
  end

  defp save_resource(socket, :edit, resource_params) do
    case Resources.update_resource(socket.assigns.resource, resource_params) do
      {:ok, _resource} ->
        {:noreply,
         socket
         |> put_flash(:info, "Resource updated successfully")
         |> push_navigate(to: ~p"/resources")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_resource(socket, _, resource_params) do
    url =
      case Resources.upload_file(socket, "/resources") do
        {:error, _e} -> "https://example.com/404"
        url when is_list(url) -> List.first(url)
        _ -> "https://example.com/404"
      end

    resource_params =
      resource_params
      |> Map.put("url", url)

    case Resources.create_resource(resource_params) do
      {:ok, _resource} ->
        {:noreply,
         socket
         |> put_flash(:info, "Resource created successfully")
         |> push_navigate(to: ~p"/resources")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Resource could not be created")
         |> assign(form: to_form(changeset))}
    end
  end
end
