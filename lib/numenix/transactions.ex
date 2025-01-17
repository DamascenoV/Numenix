defmodule Numenix.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias Numenix.Repo

  alias Numenix.Users.User
  alias Numenix.Accounts
  alias Numenix.Accounts.Account
  alias Numenix.Transactions.Type
  alias Numenix.Transactions.Category
  alias Numenix.Transactions.Transaction

  @doc """
  Returns the list of types.

  ## Examples

      iex> list_types()
      [%Type{}, ...]

  """
  def list_types, do: Repo.all(Type)
  def list_types(params), do: Flop.validate_and_run(Type, params, for: Type)

  @doc """
  Gets a single type.

  Raises `Ecto.NoResultsError` if the Type does not exist.

  ## Examples

      iex> get_type!(123)
      %Type{}

      iex> get_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_type!(id), do: Repo.get!(Type, id)

  @doc """
  Creates a type.

  ## Examples

      iex> create_type(%{field: value})
      {:ok, %Type{}}

      iex> create_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_type(attrs \\ %{}) do
    %Type{}
    |> Type.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking type changes.

  ## Examples

      iex> change_type(type)
      %Ecto.Changeset{data: %Type{}}

  """
  def change_type(%Type{} = type, attrs \\ %{}) do
    Type.changeset(type, attrs)
  end

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories(user = %User{})
      [%Category{}, ...]

  """
  def list_categories(user = %User{}) do
    Repo.all(from c in Category, where: c.user_id == ^user.id, preload: :type)
  end

  def list_categories(user = %User{}, params) do
    Category
    |> where(user_id: ^user.id)
    |> join(:left, [c], t in assoc(c, :type), as: :type)
    |> preload([t], [:type])
    |> Flop.validate_and_run(params, for: Category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id) |> Repo.preload([:type])

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%User{}, %{field: value})
      {:ok, %Category{}}

      iex> create_category(%User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(user = %User{}, attrs \\ %{}) do
    category =
      user
      |> Ecto.build_assoc(:categories)
      |> Category.changeset(attrs)
      |> Repo.insert()

    case category do
      {:ok, category} -> {:ok, category |> Repo.preload([:type])}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    case category |> Category.changeset(attrs) |> Repo.update() do
      {:ok, category} -> {:ok, category |> Repo.preload([:type])}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  @doc """
  Returns the list of all transactions of the user.

  ## Examples

      iex> list_transactions(%User{})
      [%Transaction{}, ...]

  Returns the list of all transactions of a account.

  ## Examples

      iex> list_transactions(%Account{})
      [%Transaction{}, ...]

  """
  def list_transactions(user = %User{}) do
    Repo.all(
      from t in Transaction,
        join: a in assoc(t, :account),
        where: a.user_id == ^user.id,
        preload: [:type, :category, :account]
    )
  end

  def list_transactions(account = %Account{}) do
    Repo.all(
      from t in Transaction,
        where: t.account_id == ^account.id,
        order_by: [desc: t.date],
        preload: [:type, :category, :account]
    )
  end

  def list_transactions(user = %User{}, params) do
    Transaction
    |> join(:left, [t], a in assoc(t, :account), as: :account)
    |> join(:left, [t, a], c in assoc(t, :category), as: :category)
    |> join(:left, [t, a, c], ty in assoc(t, :type), as: :type)
    |> preload([t, a, c, ty], [:account, :category, :type])
    |> where([t, a, c, ty], a.user_id == ^user.id)
    |> Flop.validate_and_run(params, for: Transaction)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id),
    do: Repo.get!(Transaction, id) |> Repo.preload([:type, :category, :account])

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    account_balance =
      case Map.has_key?(attrs, "account_id") do
        true -> Accounts.get_account!(attrs["account_id"]).balance
        false -> nil
      end

    attrs = Map.put(attrs, "account_balance", account_balance)

    case %Transaction{}
         |> Transaction.changeset(attrs)
         |> Repo.insert() do
      {:ok, transaction} ->
        Accounts.update_account_balance(:insert, transaction)
        {:ok, get_transaction!(transaction.id)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    case transaction |> Transaction.changeset(attrs) |> Repo.update() do
      {:ok, transaction} ->
        Accounts.update_account_balance(:edit, transaction)
        {:ok, transaction |> Repo.preload([:type, :category, :account])}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    {:ok, transaction} = Repo.delete(transaction)
    Accounts.update_account_balance(:delete, transaction)
    {:ok, transaction}
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end
end
