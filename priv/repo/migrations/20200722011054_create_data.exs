defmodule Textdb.Repo.Migrations.CreateData do
  use Ecto.Migration

  def up do
    create table(:data) do
      add :uuid, :string
      add :location, :string

      timestamps()
    end

    create index(:data, [:uuid])
  end

  def down do
    drop index(:data, [:uuid])
    drop table(:data)
  end
end
