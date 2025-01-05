defmodule Numenix.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    field :date, :date
    field :description, :string
    field :amount, :decimal
    field :account_balance, :decimal
    belongs_to :type, Numenix.Transactions.Type
    belongs_to :category, Numenix.Transactions.Category
    belongs_to :account, Numenix.Accounts.Account

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :date,
      :amount,
      :description,
      :type_id,
      :category_id,
      :account_id,
      :account_balance
    ])
    |> validate_required([:date, :amount, :description, :type_id, :category_id, :account_id])
  end
end
