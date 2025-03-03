defmodule Numenix.Transactions.Type do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [
      :name,
      :subtraction
    ],
    sortable: [
      :name,
      :subtraction
    ],
    max_limit: 5,
    default_limit: 5
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "types" do
    field :name, :string
    field :subtraction, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(type, attrs) do
    type
    |> cast(attrs, [:name, :subtraction])
    |> validate_required([:name, :subtraction])
  end
end
