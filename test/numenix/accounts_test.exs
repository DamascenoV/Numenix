defmodule Numenix.AccountsTest do
  use Numenix.DataCase

  alias Numenix.Accounts

  describe "account" do
    alias Numenix.Accounts.Account

    import Numenix.AccountsFixtures
    import Numenix.UsersFixtures
    import Numenix.CurrenciesFixtures

    @invalid_attrs %{name: nil, balance: nil}

    test "list_account/0 returns all account" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      assert Accounts.list_account(user) == [account]
    end

    test "get_account!/1 returns the account with given id" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      assert Accounts.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      user = user_fixture()
      currency = currency_fixture(user)
      valid_attrs = %{name: "some name", balance: "120.5", currency_id: currency.id}

      assert {:ok, %Account{} = account} = Accounts.create_account(user, valid_attrs)
      assert account.name == "some name"
      assert account.balance == Decimal.new("120.5")
    end

    test "create_account/1 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(user, @invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      update_attrs = %{name: "some updated name", balance: "456.7", currency_id: currency.id}

      assert {:ok, %Account{} = account} = Accounts.update_account(account, update_attrs)
      assert account.name == "some updated name"
      assert account.balance == Decimal.new("456.7")
    end

    test "update_account/2 with invalid data returns error changeset" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      assert {:error, %Ecto.Changeset{}} = Accounts.update_account(account, @invalid_attrs)
      assert account == Accounts.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      assert {:ok, %Account{}} = Accounts.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      assert %Ecto.Changeset{} = Accounts.change_account(account)
    end
  end

  describe "goals" do
    alias Numenix.Accounts.Goal

    import Numenix.AccountsFixtures
    import Numenix.UsersFixtures
    import Numenix.CurrenciesFixtures

    @invalid_attrs %{name: nil, done: nil, description: nil, amount: nil}

    test "list_goals/0 returns all goals" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      goal = goal_fixture(user, %{account_id: account.id})
      assert Accounts.list_goals(user) == [goal]
    end

    test "get_goal!/1 returns the goal with given id" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      goal = goal_fixture(user, %{account_id: account.id})
      assert Accounts.get_goal!(goal.id) == goal
    end

    test "create_goal/1 with valid data creates a goal" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})

      valid_attrs = %{
        name: "some name",
        done: true,
        description: "some description",
        amount: "120.5",
        account_id: account.id
      }

      assert {:ok, %Goal{} = goal} = Accounts.create_goal(user, valid_attrs)
      assert goal.name == "some name"
      assert goal.done == true
      assert goal.description == "some description"
      assert goal.amount == Decimal.new("120.5")
      assert goal.account_id == account.id
    end

    test "create_goal/1 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.create_goal(user, @invalid_attrs)
    end

    test "update_goal/2 with valid data updates the goal" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      goal = goal_fixture(user, %{account_id: account.id})

      update_attrs = %{
        name: "some updated name",
        done: false,
        description: "some updated description",
        amount: "456.7",
        account_id: account.id
      }

      assert {:ok, %Goal{} = goal} = Accounts.update_goal(goal, update_attrs)
      assert goal.name == "some updated name"
      assert goal.done == false
      assert goal.description == "some updated description"
      assert goal.amount == Decimal.new("456.7")
      assert goal.account_id == account.id
    end

    test "update_goal/2 with invalid data returns error changeset" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      goal = goal_fixture(user, %{account_id: account.id})
      assert {:error, %Ecto.Changeset{}} = Accounts.update_goal(goal, @invalid_attrs)
      assert goal == Accounts.get_goal!(goal.id)
    end

    test "delete_goal/1 deletes the goal" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      goal = goal_fixture(user, %{account_id: account.id})
      assert {:ok, %Goal{}} = Accounts.delete_goal(goal)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_goal!(goal.id) end
    end

    test "change_goal/1 returns a goal changeset" do
      user = user_fixture()
      currency = currency_fixture(user)
      account = account_fixture(user, %{currency_id: currency.id})
      goal = goal_fixture(user, %{account_id: account.id})
      assert %Ecto.Changeset{} = Accounts.change_goal(goal)
    end
  end
end
