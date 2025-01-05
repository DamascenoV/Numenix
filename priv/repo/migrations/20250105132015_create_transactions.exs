defmodule Numenix.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :date, :date
      add :description, :string
      add :amount, :decimal
      add :account_balance, :decimal
      add :category_id, references(:categories, on_delete: :nothing, type: :binary_id)
      add :account_id, references(:accounts, on_delete: :nothing, type: :binary_id)
      add :type_id, references(:types, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:category_id])
    create index(:transactions, [:account_id])
    create index(:transactions, [:type_id])
  end
end
