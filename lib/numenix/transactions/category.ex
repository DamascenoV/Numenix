defmodule Numenix.Transactions.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:name, :type_name],
    sortable: [:name, :type_name],
    max_limit: 5,
    default_limit: 5,
    adapter_opts: [
      join_fields: [
        type_name: [
          binding: :type,
          field: :name,
          ecto_type: :string
        ]
      ]
    ]
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "categories" do
    field :name, :string
    belongs_to :user, Numenix.Users.User
    belongs_to :type, Numenix.Transactions.Type

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :type_id, :user_id])
    |> validate_required([:name, :type_id])
  end
end
