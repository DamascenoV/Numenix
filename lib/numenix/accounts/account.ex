defmodule Numenix.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :name, :string
    field :balance, :decimal
    belongs_to :user, Numenix.Users.User
    belongs_to :currency, Numenix.Currencies.Currency
    has_many :goals, Numenix.Accounts.Goal

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :balance, :currency_id])
    |> validate_required([:name, :balance, :currency_id])
    |> foreign_key_constraint(:currency_id)
    |> foreign_key_constraint(:user_id)
  end
end
