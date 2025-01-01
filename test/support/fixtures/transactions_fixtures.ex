defmodule Numenix.TransactionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Numenix.Transactions` context.
  """

  @doc """
  Generate a type.
  """
  def type_fixture(attrs \\ %{}) do
    {:ok, type} =
      attrs
      |> Enum.into(%{
        name: "some name",
        subtraction: true
      })
      |> Numenix.Transactions.create_type()

    type
  end
end
