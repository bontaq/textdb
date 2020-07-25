defmodule TextdbWeb.PageController do
  use TextdbWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", %{uuid: Ecto.UUID.generate()})
  end
end
