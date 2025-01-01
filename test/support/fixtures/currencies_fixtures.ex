defmodule Numenix.CurrenciesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Numenix.Currencies` context.
  """

  @doc """
  Generate a currency.
  """
  def currency_fixture(user = %Numenix.Users.User{}, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name",
        symbol: "some symbol"
      })

    {:ok, currency} =
      Numenix.Currencies.create_currency(user, attrs)

    currency
  end
end
