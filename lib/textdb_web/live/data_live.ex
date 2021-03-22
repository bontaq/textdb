defmodule TextdbWeb.DataLive do
  use Phoenix.HTML
  use Phoenix.LiveView

  require Logger

  import NaiveDateTime

  alias Textdb.Data
  alias Textdb.Repo

  @topic "updates/"

  def mount(%{"id" => id}, %{}, socket) do
    Logger.info("Connect " <> inspect(connected?(socket)))

    TextdbWeb.Endpoint.subscribe(@topic <> id)

    data = get_data(id)
    data_hash = get_hash_data(id)

    editing_enabled =
      if data_hash do
        false
      else
        true
      end

    db_data = Data |> Repo.get_by(%{:uuid => id})

    hash =
      if db_data != nil do
        db_data.hash
      else
        ""
      end

    alignment =
      if db_data != nil do
        db_data.alignment
      else
        "center"
      end

    probably_data =
      if data == "" do
        data_hash
      else
        data
      end

    {:ok,
     assign(
       socket,
       %{
         :id => id,
         :hash => hash,
         :data => probably_data,
         :alignment => alignment,
         :time => NaiveDateTime.utc_now(),
         :editing => false,
         :editing_enabled => editing_enabled,
         :changeset => Data.changeset(%Data{}, %{})
       }
     )}
  end

  def get_hash_data(id) do
    data = Data |> Repo.get_by(%{:hash => id})

    if data do
      File.read!(data.location)
    else
      nil
    end
  end

  def get_data(id) do
    data = Data |> Repo.get_by(%{:uuid => id})

    case data do
      nil ->
        TextdbWeb.ApiController.write_file(id, "")
        ""

      _ ->
        File.read!(data.location)
    end
  end

  def get_data_with_time_check(id, time, data) do
    check_data = Data |> Repo.get_by(%{:uuid => id})

    Logger.info("updated: " <> inspect(check_data.updated_at))

    should_update = compare(check_data.updated_at, time)

    Logger.info("should_update " <> inspect(should_update))

    case should_update do
      :lt -> {data, time}
      :eq -> {data, time}
      :gt -> {File.read!(check_data.location), NaiveDateTime.utc_now()}
    end
  end

  def handle_info(%{event: "data", payload: payload}, socket) do
    {data, time} =
      get_data_with_time_check(
        socket.assigns.id,
        socket.assigns.time,
        socket.assigns.data
      )

    {:noreply, assign(socket, %{:data => data, :time => time})}
  end

  def save_data(id, new_data) do
    TextdbWeb.ApiController.write_file(id, new_data)
    new_data
  end

  def handle_event("start_edit", _value, socket) do
    {:noreply, assign(socket, :editing, true)}
  end

  def handle_event("cancel_edit", _value, socket) do
    {:noreply, assign(socket, :editing, false)}
  end

  def handle_event("save_edit", value, socket) do
    if socket.assigns.editing do
      %{"data" => %{"data" => new_value}} = value
      from_save = save_data(socket.assigns.id, new_value)

      {:noreply, assign(socket, %{:editing => false, :data => from_save})}
    else
      {:noreply, assign(socket, %{:editing => false, :data => socket.assigns.data})}
    end
  end

  def handle_event("update_alignment", %{"value" => value}, socket) do
    Task.start(fn -> save_change_alignment(socket.assigns.id, value) end)

    {:noreply, assign(socket, %{:alignment => value})}
  end

  def save_change_alignment(id, value) do
    data = Data |> Repo.get_by(%{:uuid => id})

    case data do
      nil ->
        TextdbWeb.ApiController.write_file(id, "")

      _ ->
        nil
    end

    data = Data |> Repo.get_by(%{:uuid => id})

    data
    |> Data.changeset(%{alignment: value})
    |> Repo.update()
  end
end
