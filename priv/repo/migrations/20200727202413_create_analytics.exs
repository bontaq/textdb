defmodule Textdb.Repo.Migrations.CreateAnalytics do
  use Ecto.Migration

  def change do
    create table(:analytics) do
      add :topic, :string
      add :subtopic, :string
      add :count, :integer
      add :date, :date

      timestamps()
    end

  end
end
