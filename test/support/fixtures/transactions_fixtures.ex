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

  @doc """
  Generate a category.
  """
  def category_fixture(user = %Numenix.Users.User{}, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name"
      })

    {:ok, category} =
      Numenix.Transactions.create_category(user, attrs)

    Numenix.Transactions.get_category!(category.id)
  end

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        "amount" => "120.5",
        "date" => ~D[2025-01-04],
        "description" => "some description"
      })
      |> Numenix.Transactions.create_transaction()

    Numenix.Transactions.get_transaction!(transaction.id)
  end
end
