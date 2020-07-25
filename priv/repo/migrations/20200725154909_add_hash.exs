defmodule Textdb.Repo.Migrations.AddHash do
  use Ecto.Migration

  def up do
    alter table(:data) do
      add :hash, :string
    end

    create index(:data, [:hash])
  end

  def down do
    drop index(:data, [:hash])

    alter table(:data) do
      remove :hash
    end
  end
end
