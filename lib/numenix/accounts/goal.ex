defmodule Numenix.Accounts.Goal do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:name, :description, :amount, :done, :account_id],
    sortable: [:name, :description, :amount, :done, :account_id],
    max_limit: 5,
    default_limit: 5
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "goals" do
    field :name, :string
    field :done, :boolean, default: false
    field :description, :string
    field :amount, :decimal, default: 0
    belongs_to :user, Numenix.Users.User
    belongs_to :account, Numenix.Accounts.Account

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(goal, attrs) do
    goal
    |> cast(attrs, [:name, :description, :amount, :done, :account_id])
    |> validate_required([:name, :description, :amount, :done, :account_id])
  end
end
