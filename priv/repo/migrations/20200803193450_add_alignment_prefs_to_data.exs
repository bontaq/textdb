defmodule Textdb.Repo.Migrations.AddAlignmentPrefsToData do
  use Ecto.Migration

  def change do
    alter table(:data) do
      add :alignment, :string, size: 10, default: "center"
    end
  end
end
