defmodule TextdbWeb.ApiController do
  use TextdbWeb, :controller

  require Logger

  import Ecto

  alias Textdb.Data
  alias Textdb.Repo


  def data_requested() do
    today = NaiveDateTime.utc_now() |> NaiveDateTime.to_date()

    analytic = Analytic |> Repo.get_by(%{
       topic: "data_requested",
       date: today
    })

    case analytic do
      nil -> %Analytic{topic: "data_requested", date: today, count: 0} |> Repo.insert()
      _ ->
        analytic
        |> Analytic.changeset(%{ count: analytic.count + 1})
        |> Repo.update()
    end
  end

  def data_written() do
    today = NaiveDateTime.utc_now() |> NaiveDateTime.to_date()

    analytic = Analytic |> Repo.get_by(%{
       topic: "data_written",
       date: today
    })

    case analytic do
      nil -> %Analytic{topic: "data_written", date: today, count: 0} |> Repo.insert()
      _ ->
        analytic
        |> Analytic.changeset(%{ count: analytic.count + 1})
        |> Repo.update()
    end
  end

  def write_file(id, data) do
    location = "./priv/static/data/" <> id

    data_data = Data |> Repo.get_by(%{:uuid => id})
    data_hash = Data |> Repo.get_by(%{:hash => id})
    key = Application.get_env(:textdb, TextdbWeb.Endpoint)[:hash_secret]

    Task.start(fn -> data_written() end)

    if data_hash != nil do
      "Writing not allowed with this endpoint"
    else
      File.write!(location, data)

      if data_data == nil do
        %Data{location: location,
              uuid: id,
              hash: :crypto.hmac(:sha256, key, id) |> Base.encode16}
        |> Repo.insert!
      else
        new_time = NaiveDateTime.truncate(NaiveDateTime.utc_now, :second)

        data_data
        |> Ecto.Changeset.change(updated_at: new_time)
        |> Repo.update!
      end

      TextdbWeb.Endpoint.broadcast_from!(
        self(),
        "updates/" <> id,
        "data", %{}
      )

      data
    end
  end

  def write_data("text/plain", id, conn) do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)
    new_body = write_file(id, body)

    text conn, new_body
  end

  def write_data("application/json", id, conn) do
    json_string = Jason.encode!(conn.body_params)

    new_body = write_file(id, json_string)

    json conn, new_body
  end

  def write_data("application/x-www-form-urlencoded", id, conn) do
    form_encoded =
      conn.body_params
      |> Map.to_list
      |> Enum.map(fn {x, y} -> "#{x}=#{y}" end)
      |> Enum.join("&")

    new_body = write_file(id, form_encoded)

    text conn, new_body
  end

  def update_data(conn, params) do
    Logger.info(inspect(params))

    content_type = conn |> get_req_header("content-type") |> List.first
    id = params |> Map.get("id")

    write_data(content_type, id, conn)
  end

  def fetch_data(conn, %{"id" => id}) do
    data = Data |> Repo.get_by(%{:uuid => id})

    data =
      case data do
        nil -> Data |> Repo.get_by(%{:hash => id})
        _ -> data
      end

    content_type = conn |> get_req_header("accept") |> List.first

    Task.start(fn -> data_requested() end)

    case data do
      nil ->
        write_file(id, "")
        case content_type do
          "application/json" -> json conn, ""
          _ -> text conn, ""
        end
      info ->
        case content_type do
          "application/json" -> json conn, File.read!(info.location)
          _ -> text conn, File.read!(info.location)
        end
    end
  end
end
