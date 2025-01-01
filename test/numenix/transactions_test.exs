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
end
