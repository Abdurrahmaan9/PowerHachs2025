defmodule MindSanctuaryWeb.CalendarLive.Index do
  use MindSanctuaryWeb, :live_view

  alias MindSanctuary.Calendar
  alias MindSanctuary.Calendar.Schedule

  @impl true
  def mount(_params, _session, socket) do
    today = Date.utc_today()
    {:ok,
     socket
     |> assign(page_title: "Calendar")
     |> assign(view_date: Date.new!(today.year, today.month, 1), selected_date: nil, modal_open: false)
     |> load_month()
     |> assign_form(Calendar.change_schedule(%Schedule{}))}
  end

  defp load_month(socket) do
    %{view_date: view_date} = socket.assigns
    from_dt = view_date |> Date.beginning_of_month() |> NaiveDateTime.new!(~T[00:00:00])
    to_dt = view_date |> Date.end_of_month() |> NaiveDateTime.new!(~T[23:59:59])

    schedules = Calendar.list_schedules_in_range(socket.assigns.current_scope, from_dt, to_dt)
    events_by_date =
      schedules
      |> Enum.group_by(fn s -> NaiveDateTime.to_date(s.starts_at) end)

    days = calendar_grid(view_date)

    assign(socket, schedules: schedules, events_by_date: events_by_date, days: days)
  end

  defp assign_form(socket, changeset) do
    assign(socket, form: to_form(changeset))
  end

  @impl true
  def handle_event("save", %{"schedule" => params}, socket) do
    case Calendar.create_schedule(socket.assigns.current_scope, params) do
      {:ok, _schedule} ->
        {:noreply,
         socket
         |> load_month()
         |> assign(modal_open: false, selected_date: nil)
         |> assign_form(Calendar.change_schedule(%Schedule{}))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def handle_event("prev_month", _params, socket) do
    %{view_date: d} = socket.assigns
    d = shift_month(d, -1)
    {:noreply, socket |> assign(view_date: d) |> load_month()}
  end

  @impl true
  def handle_event("next_month", _params, socket) do
    %{view_date: d} = socket.assigns
    d = shift_month(d, 1)
    {:noreply, socket |> assign(view_date: d) |> load_month()}
  end

  @impl true
  def handle_event("select_date", %{"date" => date_iso}, socket) do
    {:ok, date} = Date.from_iso8601(date_iso)
    # prefill starts_at to clicked date at 09:00 by default
    starts = NaiveDateTime.new!(date, ~T[09:00:00])
    changeset = Calendar.change_schedule(%Schedule{}, %{starts_at: starts})
    {:noreply, socket |> assign(selected_date: date, modal_open: true) |> assign_form(changeset)}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, modal_open: false, selected_date: nil)}
  end

  defp shift_month(%Date{year: y, month: m} = _d, delta) do
    m2 = m + delta
    {y2, m2} =
      cond do
        m2 < 1 -> {y - 1, 12}
        m2 > 12 -> {y + 1, 1}
        true -> {y, m2}
      end
    Date.new!(y2, m2, 1)
  end

  defp calendar_grid(%Date{} = month_start) do
    first = Date.beginning_of_month(month_start)
    last = Date.end_of_month(month_start)
    # Calculate start on Sunday (or Monday). We'll use Sunday-start grid like the screenshot.
    wday = Date.day_of_week(first) # 1..7 (Mon..Sun)
    grid_start = Date.add(first, -rem(wday, 7))
    # 6 weeks grid
    for i <- 0..41 do
      Date.add(grid_start, i)
    end
    |> Enum.chunk_every(7)
  end
end
