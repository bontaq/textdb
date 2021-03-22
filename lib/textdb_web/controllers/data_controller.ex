defmodule TextdbWeb.DataController do
  use TextdbWeb, :controller
  use Phoenix.LiveView

  require Logger

  import Ecto
  import Ecto.Query
  alias Textdb.Data
  alias Textdb.Repo

  def read_or_create(id) do
    read_data =
      Data
      |> Repo.get_by(%{:uuid => id})

    case read_data do
      nil ->
        "Not found"

      info ->
        File.read!(info.location)
    end
  end

  def data(conn, %{"id" => id}) do
    Logger.info(id)
    data = read_or_create(id)
    Logger.info(data)
    # if it doesn't exist, create it
    # create the file
    # return blank

    # find the file
    # read the file
    # render(conn, "data.html", %{data: data})
  end

  def render(assigns) do
    # Phoenix.View.render(conn, "data.html", %{})
    # ~L"""
    # Current temperature:
    # """
  end

  def mount(_params, %{}, socket) do
    {:ok, socket}
  end
end
