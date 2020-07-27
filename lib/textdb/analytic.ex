defmodule Textdb.Analytic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "analytics" do
    field :count, :integer
    field :date, :date
    field :subtopic, :string
    field :topic, :string

    timestamps()
  end

  @doc false
  def changeset(analytic, attrs) do
    analytic
    |> cast(attrs, [:topic, :subtopic, :count, :date])
    |> validate_required([:topic, :subtopic, :count, :date])
  end
end
