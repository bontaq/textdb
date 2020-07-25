defmodule Textdb.Repo do
  use Ecto.Repo,
    otp_app: :textdb,
    adapter: Ecto.Adapters.Postgres
end
