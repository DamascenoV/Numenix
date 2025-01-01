defmodule Numenix.Repo.Migrations.CreateCurrencies do
  use Ecto.Migration

  def change do
    create table(:currencies, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :symbol, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:currencies, [:user_id])
  end
end
