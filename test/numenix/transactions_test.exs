defmodule Numenix.TransactionsTest do
  use Numenix.DataCase

  alias Numenix.Transactions

  describe "types" do
    alias Numenix.Transactions.Type

    import Numenix.TransactionsFixtures

    @invalid_attrs %{name: nil, subtraction: nil}

    test "list_types/0 returns all types" do
      type = type_fixture()
      assert Transactions.list_types() == [type]
    end

    test "get_type!/1 returns the type with given id" do
      type = type_fixture()
      assert Transactions.get_type!(type.id) == type
    end

    test "create_type/1 with valid data creates a type" do
      valid_attrs = %{name: "some name", subtraction: true}

      assert {:ok, %Type{} = type} = Transactions.create_type(valid_attrs)
      assert type.name == "some name"
      assert type.subtraction == true
    end

    test "create_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_type(@invalid_attrs)
    end

    test "change_type/1 returns a type changeset" do
      type = type_fixture()
      assert %Ecto.Changeset{} = Transactions.change_type(type)
    end
  end

  describe "categories" do
    alias Numenix.Transactions.Category

    import Numenix.TransactionsFixtures
    import Numenix.UsersFixtures

    @invalid_attrs %{name: nil}

    test "list_categories/0 returns all categories" do
      user = user_fixture()
      type = type_fixture()
      category = category_fixture(user, %{type_id: type.id})
      assert Transactions.list_categories(user) == [category]
    end

    test "get_category!/1 returns the category with given id" do
      user = user_fixture()
      type = type_fixture()
      category = category_fixture(user, %{type_id: type.id})
      assert Transactions.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      user = user_fixture()
      type = type_fixture()
      valid_attrs = %{name: "some name", type_id: type.id}

      assert {:ok, %Category{} = category} = Transactions.create_category(user, valid_attrs)
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Transactions.create_category(user, @invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      user = user_fixture()
      type = type_fixture()
      category = category_fixture(user, %{type_id: type.id})
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Category{} = category} = Transactions.update_category(category, update_attrs)
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      user = user_fixture()
      type = type_fixture()
      category = category_fixture(user, %{type_id: type.id})
      assert {:error, %Ecto.Changeset{}} = Transactions.update_category(category, @invalid_attrs)
      assert category == Transactions.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      user = user_fixture()
      type = type_fixture()
      category = category_fixture(user, %{type_id: type.id})
      assert {:ok, %Category{}} = Transactions.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Transactions.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      user = user_fixture()
      type = type_fixture()
      category = category_fixture(user, %{type_id: type.id})
      assert %Ecto.Changeset{} = Transactions.change_category(category)
    end
  end

  describe "transactions" do
    alias Numenix.Transactions.Transaction

    import Numenix.{TransactionsFixtures, UsersFixtures, CurrenciesFixtures, AccountsFixtures}

    @invalid_attrs %{
      "date" => nil,
      "description" => nil,
      "amount" => nil,
      "account_id" => nil,
      "category_id" => nil,
      "type_id" => nil
    }

    test "list_transactions/0 returns all transactions" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      type = type_fixture()
      category = category_fixture(user, %{type_id: type.id})

      transaction =
        transaction_fixture(%{
          "account_id" => account.id,
          "category_id" => category.id,
          "type_id" => type.id
        })

      assert Transactions.list_transactions(user) == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      type = type_fixture()
      category = category_fixture(user, %{type_id: type.id})

      transaction =
        transaction_fixture(%{
          "account_id" => account.id,
          "category_id" => category.id,
          "type_id" => type.id
        })

      assert Transactions.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      type = type_fixture()
      category = category_fixture(user, %{type_id: type.id})

      valid_attrs = %{
        "date" => ~D[2025-01-04],
        "description" => "some description",
        "amount" => "120.5",
        "account_id" => account.id,
        "category_id" => category.id,
        "type_id" => type.id
      }

      valid_attrs = Map.put(valid_attrs, "account_id", account.id)

      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(valid_attrs)
      assert transaction.date == ~D[2025-01-04]
      assert transaction.description == "some description"
      assert transaction.amount == Decimal.new("120.5")
      assert transaction.account_balance == account.balance
      assert transaction.category_id == category.id
      assert transaction.type_id == type.id
      assert transaction.account_id == account.id
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      type = type_fixture()
      category = category_fixture(user, %{type_id: type.id})

      assert {:error, %Ecto.Changeset{}} =
               Transactions.create_transaction(%{
                 "date" => ~D[2024-05-02],
                 "description" => "some description",
                 "amount" => nil,
                 "account_id" => account.id,
                 "category_id" => category.id,
                 "type_id" => type.id
               })
    end

    test "update_transaction/2 with valid data updates the transaction" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      type = type_fixture()
      category = category_fixture(user, %{type_id: type.id})

      transaction =
        transaction_fixture(%{
          "account_id" => account.id,
          "category_id" => category.id,
          "type_id" => type.id
        })

      update_attrs = %{
        date: ~D[2025-01-05],
        description: "some updated description",
        amount: "456.7"
      }

      assert {:ok, %Transaction{} = transaction} =
               Transactions.update_transaction(transaction, update_attrs)

      assert transaction.date == ~D[2025-01-05]
      assert transaction.description == "some updated description"
      assert transaction.amount == Decimal.new("456.7")
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      type = type_fixture()
      category = category_fixture(user, %{type_id: type.id})

      transaction =
        transaction_fixture(%{
          "account_id" => account.id,
          "category_id" => category.id,
          "type_id" => type.id
        })

      assert {:error, %Ecto.Changeset{}} =
               Transactions.update_transaction(transaction, @invalid_attrs)

      assert transaction == Transactions.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      type = type_fixture()
      category = category_fixture(user, %{type_id: type.id})

      transaction =
        transaction_fixture(%{
          "account_id" => account.id,
          "category_id" => category.id,
          "type_id" => type.id
        })

      assert {:ok, %Transaction{}} = Transactions.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Transactions.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      type = type_fixture()
      category = category_fixture(user, %{type_id: type.id})

      transaction =
        transaction_fixture(%{
          "account_id" => account.id,
          "category_id" => category.id,
          "type_id" => type.id
        })

      assert %Ecto.Changeset{} = Transactions.change_transaction(transaction)
    end
  end
end
