defmodule MindSanctuary.Calendar do
  @moduledoc false

  import Ecto.Query
  alias MindSanctuary.Repo
  alias MindSanctuary.Calendar.Schedule

  # current_scope must be passed as first argument (per app guidelines)
  def list_schedules(current_scope) do
    from(s in Schedule, where: s.user_id == ^current_scope.user.id, order_by: [asc: s.starts_at])
    |> Repo.all()
  end

  def list_schedules_in_range(current_scope, from_dt, to_dt) do
    from(s in Schedule,
      where: s.user_id == ^current_scope.user.id,
      where: s.starts_at >= ^from_dt and s.starts_at <= ^to_dt,
      order_by: [asc: s.starts_at]
    )
    |> Repo.all()
  end

  def change_schedule(%Schedule{} = schedule, attrs \\ %{}) do
    Schedule.changeset(schedule, attrs)
  end

  def create_schedule(current_scope, attrs) do
    %Schedule{user_id: current_scope.user.id}
    |> Schedule.changeset(attrs)
    |> Repo.insert()
  end
end
