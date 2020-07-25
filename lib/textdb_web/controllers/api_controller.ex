defmodule TextdbWeb.ApiController do
  use TextdbWeb, :controller

  require Logger

  import Ecto

  alias Textdb.Data
  alias Textdb.Repo

  def write_file(id, data) do
    location = "./priv/static/data/" <> id

    File.write!(location, data)

    data = Data |> Repo.get_by(%{:uuid => id})
    data_hash = Data |> Repo.get_by(%{:uuid => id})
    key = Application.get_env(:textdb, TextdbWeb.Endpoint)[:hash_secret]

    Logger.info(key)

    if data_hash do
      "Writing not allowed with this endpoint"
    else
      if data == nil do
        %Data{location: location,
              uuid: id,
              hash: :crypto.hmac(:sha256, key, id) |> Base.encode16}
        |> Repo.insert!
      else
        new_time = NaiveDateTime.truncate(NaiveDateTime.utc_now, :second)

        data
        |> Ecto.Changeset.change(updated_at: new_time)
        |> Repo.update!
      end

      TextdbWeb.Endpoint.broadcast_from!(
        self(),
        "updates/" <> id,
        "data", %{}
      )
    end
  end

  def write_data("text/plain", id, conn) do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)
    write_file(id, body)

    text conn, body
  end

  def write_data("application/json", id, conn) do
    json_string = Jason.encode!(conn.body_params)

    write_file(id, json_string)

    json conn, conn.body_params
  end

  def write_data("application/x-www-form-urlencoded", id, conn) do
    form_encoded =
      conn.body_params
      |> Map.to_list
      |> Enum.map(fn {x, y} -> "#{x}=#{y}" end)
      |> Enum.join("&")

    write_file(id, form_encoded)

    text conn, form_encoded
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

    Logger.info(inspect(content_type))

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
