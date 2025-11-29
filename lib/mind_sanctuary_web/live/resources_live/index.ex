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

    # Default SOS contacts
    sos_contacts = [
      %{
        id: :sos_1,
        title: "National Suicide Prevention Lifeline",
        description: "24/7 free and confidential support for people in distress",
        url: "tel:988",
        type: "contact",
        is_featured: false,
        inserted_at: DateTime.utc_now(),
        category: "safety",
        access_level: "public"
      },
      %{
        id: :sos_2,
        title: "Crisis Text Line",
        description: "Text HOME to 741741 from anywhere in the US, anytime, about any type of crisis",
        url: "tel:741741",
        type: "contact",
        is_featured: false,
        inserted_at: DateTime.utc_now(),
        category: "safety",
        access_level: "public"
      },
      %{
        id: :sos_3,
        title: "SAMHSA National Helpline",
        description: "Treatment referral and information service 1-800-662-HELP (4357)",
        url: "tel:1-800-662-4357",
        type: "contact",
        is_featured: false,
        inserted_at: DateTime.utc_now(),
        category: "safety",
        access_level: "public"
      },
      %{
        id: :sos_4,
        title: "The Trevor Project",
        description: "Crisis intervention and suicide prevention services for LGBTQ youth",
        url: "tel:1-866-488-7386",
        type: "contact",
        is_featured: false,
        inserted_at: DateTime.utc_now(),
        category: "safety",
        access_level: "public"
      }
    ]

    all_resources = resources ++ sos_contacts

    form = to_form(%{"q" => ""})

    {:ok,
     socket
     |> assign(page_title: "Resource Hub")
     |> assign(form: form, resources: all_resources, filtered_resources: all_resources)
     |> assign(:changeset, to_form(Resources.change_resource(%Resource{})))
     |> assign(:current_filter, "all")
     |> assign(:sos_contacts, sos_contacts)
     |> assign(:resource, %Resource{})
     |> assign(:featured_resources, featured_resources)
     |> assign(:show_form, false)
     |> assign(:editing_resource, false)
     |> assign(show_form: false)
     |> allow_upload(:file_url, accept: ~w(.pdf .png .jpeg .mp3 .mp4), max_entries: 1)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket = assign(socket, :params, params)

    # Handle category parameter for direct tab navigation
    case params do
      %{"category" => category} when category in ["all", "articles", "audio", "contacts"] ->
        filtered_resources =
          case category do
            "all" ->
              socket.assigns.resources
            "articles" ->
              Enum.filter(socket.assigns.resources, &(&1.type == "article"))
            "audio" ->
              Enum.filter(socket.assigns.resources, &(&1.type == "audio"))
            "contacts" ->
              Enum.filter(socket.assigns.resources, &(&1.type == "contact"))
            _ ->
              socket.assigns.resources
          end

        {:noreply,
         socket
         |> assign(:current_filter, category)
         |> assign(:filtered_resources, filtered_resources)}
      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("filter_resources", %{"category" => category}, socket) do
    filtered_resources =
      case category do
        "all" ->
          socket.assigns.resources
        "articles" ->
          Enum.filter(socket.assigns.resources, &(&1.type == "article"))
        "audio" ->
          Enum.filter(socket.assigns.resources, &(&1.type == "audio"))
        "contacts" ->
          Enum.filter(socket.assigns.resources, &(&1.type == "contact"))
        _ ->
          socket.assigns.resources
      end

    {:noreply,
     socket
     |> assign(:current_filter, category)
     |> assign(:filtered_resources, filtered_resources)}
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
    # Don't allow deletion of SOS contacts (they have atom ids)
    if is_atom(id) do
      {:noreply, put_flash(socket, :error, "Cannot delete default SOS contacts")}
    else
      resource = Resources.get_resource!(id)
      {:ok, _} = Resources.delete_resource(resource)

      resources = Resources.list_resources(socket.assigns.current_scope)
      all_resources = resources ++ socket.assigns.sos_contacts

      featured_resources =
        all_resources
        |> Enum.filter(fn
          r -> r.is_featured == true
        end)

      {:noreply,
       socket
       |> assign(
         resources: all_resources,
         filtered_resources: all_resources,
         featured_resources: featured_resources
       )
       |> put_flash(:info, "Resource deleted successfully")}
    end
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
    # Only upload file if upload_file is true
    url =
      if resource_params["upload_file"] == "true" do
        case Resources.upload_file(socket, "/resources") do
          {:error, _e} -> resource_params["url"] || "https://example.com/404"
          url when is_list(url) -> List.first(url)
          _ -> resource_params["url"] || "https://example.com/404"
        end
      else
        resource_params["url"]
      end

    resource_params =
      resource_params
      |> Map.put("url", url)

    case Resources.create_resource(resource_params) do
      {:ok, _resource} ->
        resources = Resources.list_resources(socket.assigns.current_scope)
        all_resources = resources ++ socket.assigns.sos_contacts
        featured_resources = Enum.filter(all_resources, & &1.is_featured)

        {:noreply,
         socket
         |> assign(:resources, all_resources)
         |> assign(:featured_resources, featured_resources)
         |> assign(:filtered_resources, all_resources)
         |> assign(:show_form, false)
         |> assign(:changeset, to_form(Resources.change_resource(%Resource{})))
         |> put_flash(:info, "Resource created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Resource could not be created")
         |> assign(changeset: to_form(changeset))}
    end
  end
end
