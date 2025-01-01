defmodule Numenix.CurrenciesTest do
  use Numenix.DataCase

  alias Numenix.Currencies

  describe "currencies" do
    alias Numenix.Currencies.Currency

    import Numenix.CurrenciesFixtures
    import Numenix.UsersFixtures

    @invalid_attrs %{name: nil, symbol: nil}

    test "list_currencies/0 returns all currencies" do
      user = user_fixture()
      currency = currency_fixture(user)
      assert Currencies.list_currencies(user) == [currency]
    end

    test "get_currency!/1 returns the currency with given id" do
      user = user_fixture()
      currency = currency_fixture(user)
      assert Currencies.get_currency!(currency.id) == currency
    end

    test "create_currency/1 with valid data creates a currency" do
      valid_attrs = %{name: "some name", symbol: "some symbol"}
      user = user_fixture()

      assert {:ok, %Currency{} = currency} = Currencies.create_currency(user, valid_attrs)
      assert currency.name == "some name"
      assert currency.symbol == "some symbol"
    end

    test "create_currency/1 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Currencies.create_currency(user, @invalid_attrs)
    end

    test "update_currency/2 with valid data updates the currency" do
      user = user_fixture()
      currency = currency_fixture(user)
      update_attrs = %{name: "some updated name", symbol: "some updated symbol"}

      assert {:ok, %Currency{} = currency} = Currencies.update_currency(currency, update_attrs)
      assert currency.name == "some updated name"
      assert currency.symbol == "some updated symbol"
    end

    test "update_currency/2 with invalid data returns error changeset" do
      user = user_fixture()
      currency = currency_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Currencies.update_currency(currency, @invalid_attrs)
      assert currency == Currencies.get_currency!(currency.id)
    end

    test "delete_currency/1 deletes the currency" do
      user = user_fixture()
      currency = currency_fixture(user)
      assert {:ok, %Currency{}} = Currencies.delete_currency(currency)
      assert_raise Ecto.NoResultsError, fn -> Currencies.get_currency!(currency.id) end
    end

    test "change_currency/1 returns a currency changeset" do
      user = user_fixture()
      currency = currency_fixture(user)
      assert %Ecto.Changeset{} = Currencies.change_currency(currency)
    end
  end
end
