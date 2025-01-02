defmodule Numenix.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:account, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :balance, :decimal
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :currency_id, references(:currencies, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:account, [:user_id])
    create index(:account, [:currency_id])
  end
end
