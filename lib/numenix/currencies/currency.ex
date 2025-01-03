defmodule Numenix.Currencies.Currency do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "currencies" do
    field :name, :string
    field :symbol, :string
    belongs_to :user, Numenix.Users.User
    has_many :accounts, Numenix.Accounts.Account

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, [:name, :symbol])
    |> validate_required([:name, :symbol])
  end
end
