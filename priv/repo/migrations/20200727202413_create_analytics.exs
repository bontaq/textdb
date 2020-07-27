defmodule Textdb.Repo.Migrations.CreateAnalytics do
  use Ecto.Migration

  def up do
    create table(:analytics) do
      add :topic, :string
      add :subtopic, :string
      add :count, :integer
      add :date, :date

      timestamps()
    end

    create index(:analytics, [:date])
    create index(:analytics, [:topic])
  end

  def down do
    drop index(:analytics, [:date])
    drop index(:analytics, [:topic])
    drop table(:analytics)
  end
end
