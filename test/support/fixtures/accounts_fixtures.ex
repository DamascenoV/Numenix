defmodule Numenix.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Numenix.Accounts` context.
  """

  @doc """
  Generate a account.
  """
  def account_fixture(user, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        balance: "120.5",
        name: "some name"
      })

    {:ok, account} =
      Numenix.Accounts.create_account(user, attrs)

    account.id |> Numenix.Accounts.get_account!()
  end
end
