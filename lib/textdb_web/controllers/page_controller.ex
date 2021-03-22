defmodule TextdbWeb.PageController do
  use TextdbWeb, :controller

  alias Textdb.Repo
  alias Textdb.Analytic

  def page_viewed() do
    today = NaiveDateTime.utc_now() |> NaiveDateTime.to_date()

    analytic =
      Analytic
      |> Repo.get_by(%{
        topic: "landing_page",
        date: today
      })

    case analytic do
      nil ->
        %Analytic{topic: "landing_page", date: today, count: 0} |> Repo.insert()

      _ ->
        analytic
        |> Analytic.changeset(%{count: analytic.count + 1})
        |> Repo.update()
    end
  end

  def index(conn, _params) do
    Task.start(fn -> page_viewed() end)
    render(conn, "index.html", %{uuid: Ecto.UUID.generate()})
  end
end
