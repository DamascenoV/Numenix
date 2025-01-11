defmodule Numenix.Currencies.Currency do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:name, :symbol], sortable: [:name, :symbol], max_limit: 5, default_limit: 5
  }

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
    |> unique_constraint(:symbol)
  end

  @doc """
  Changeset specifically for handling deletion with foreign key constraints
  """
  def delete_changeset(currency) do
    currency
    |> change()
    |> no_assoc_constraint(:accounts,
      message: "Cannot delete currency that is being used by accounts"
    )
  end
end
