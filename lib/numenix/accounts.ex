defmodule Numenix.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Numenix.Repo

  alias Numenix.Accounts.Account
  alias Numenix.Users.User

  @doc """
  Returns the list of account.

  ## Examples

      iex> list_account(user = %User{})
      [%Account{}, ...]

  """
  def list_account(user = %User{}) do
    Repo.all(from a in Account, where: a.user_id == ^user.id, preload: :currency)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id) |> Repo.preload([:currency])

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%User{}, %{field: value})
      {:ok, %Account{}}

      iex> create_account(%User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(user = %User{}, attrs \\ %{}) do
    account =
      user
      |> Ecto.build_assoc(:accounts)
      |> Account.changeset(attrs)
      |> Repo.insert()

    case account do
      {:ok, account} -> {:ok, account |> Repo.preload([:currency])}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end
end
