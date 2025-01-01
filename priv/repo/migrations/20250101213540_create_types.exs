defmodule Numenix.Repo.Migrations.CreateTypes do
  use Ecto.Migration

  def change do
    create table(:types, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :subtraction, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
