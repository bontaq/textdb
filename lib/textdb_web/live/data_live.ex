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

    # if connected?(socket), do: Process.send_after(self(), :update, 3000)

    data = get_data(id)

    {:ok,
     assign(socket,
       %{
         :id => id,
         :data => data,
         :time => NaiveDateTime.utc_now,
         :editing => false,
         :changeset => Data.changeset(%Data{}, %{})
       })}
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
      :gt -> {File.read!(check_data.location), NaiveDateTime.utc_now}
    end
  end

  # def handle_info(:update, socket) do
  #   Process.send_after(self(), :update, 10000)
  #   Logger.info("Connect " <> inspect(connected?(socket)))

  #   id = socket.assigns.id

  #   {data, time} = get_data_with_time_check(
  #     id,
  #     socket.assigns.time,
  #     socket.assigns.data
  #   )

  #   {:noreply, assign(socket, %{:data => data, :time => time})}
  # end

  def handle_info(%{event: "data", payload: payload}, socket) do
    {data, time} = get_data_with_time_check(
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
    Logger.info(inspect(value))

    %{"data" => %{"data" => new_value}} = value
    from_save = save_data(socket.assigns.id, new_value)

    {:noreply,
     assign(socket, %{:editing => false,
                      :data => from_save})}
  end
end
