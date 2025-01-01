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
end
