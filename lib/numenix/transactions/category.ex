defmodule Numenix.Transactions.Category do
  use Ecto.Schema
  import Ecto.Changeset

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
