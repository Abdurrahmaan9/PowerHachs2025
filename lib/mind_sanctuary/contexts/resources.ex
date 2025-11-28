defmodule MindSanctuary.Resources do
  @moduledoc false

  import Ecto.Query
  alias MindSanctuary.Repo
  alias MindSanctuary.Resources.Resource
  # current_scope must be passed as first argument (per app guidelines)
  def list_resources(current_scope) do
    is_admin? = String.contains?(current_scope.user.role, "admin")

    from(s in Resource,
      where:
        ^is_admin? == true or s.access_level == ^"public" or
          s.access_level == ^current_scope.user.role,
      order_by: [asc: s.inserted_at]
    )
    |> Repo.all()
  end

  def list_resources_in_range(current_scope, from_dt, to_dt) do
    from(s in Resource,
      where: s.user_id == ^current_scope.user.id,
      where: s.inserted_at >= ^from_dt and s.inserted_at <= ^to_dt,
      order_by: [asc: s.inserted_at]
    )
    |> Repo.all()
  end

  def change_resource(%Resource{} = schedule, attrs \\ %{}) do
    Resource.changeset(schedule, attrs)
  end

  def create_resource(attrs) do
    %Resource{}
    |> Resource.changeset(attrs)
    |> Repo.insert()
  end

  def get_resource!(id), do: Repo.get!(Resource, id)

  def update_resource(%Resource{} = resource, attrs) do
    resource
    |> Resource.changeset(attrs)
    |> Repo.update()
  end

  def delete_resource(%Resource{} = resource) do
    Repo.delete(resource)
  end

  def upload_file(socket, route) do
    Phoenix.LiveView.consume_uploaded_entries(socket, :file_url, fn %{path: tmp_path}, entry ->
      filename = entry.client_name
      ext = Path.extname(filename)
      basename = Path.rootname(filename, ext)
      unique_id = :erlang.unique_integer([:positive, :monotonic])

      # upload_dir = Application.get_env(:mind_sanctuary, :resources_upload_dir)
      upload_dir = "priv/static"

      unique_filename = "#{basename}_#{unique_id}#{ext}"

      dest_dir = Path.join(upload_dir, route)

      File.mkdir_p!(dest_dir)
      dest = Path.join(dest_dir, unique_filename)

      File.cp!(tmp_path, dest)
      {:ok, "#{route}/#{unique_filename}"}
    end)
  end
end
