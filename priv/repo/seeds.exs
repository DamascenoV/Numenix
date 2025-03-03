# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Numenix.Repo.insert!(%Numenix.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Create transaction types
types = [
  %{name: "Income", subtraction: false},
  %{name: "Expense", subtraction: true}
]

Enum.each(types, &Numenix.Transactions.create_type(&1))
