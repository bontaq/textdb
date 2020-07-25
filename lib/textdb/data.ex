defmodule Textdb.Data do
  use Ecto.Schema
  import Ecto.Changeset

  schema "data" do
    field :location, :string
    field :uuid, :string
    field :hash, :string

    timestamps()
  end

  @doc false
  def changeset(data, attrs) do
    data
    |> cast(attrs, [:uuid, :location])
    |> validate_required([:uuid, :location])
  end
end
