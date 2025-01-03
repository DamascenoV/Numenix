defmodule Numenix.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Numenix.Repo

  alias Numenix.Accounts.Account
  alias Numenix.Accounts.Goal
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

  @doc """
  Returns the list of goals.

  ## Examples

      iex> list_goals(%User{})
      [%Goal{}, ...]

  """
  def list_goals(user = %User{}) do
    Repo.all(from g in Goal, where: g.user_id == ^user.id, preload: :account)
  end

  @doc """
  Gets a single goal.

  Raises `Ecto.NoResultsError` if the Goal does not exist.

  ## Examples

      iex> get_goal!(123)
      %Goal{}

      iex> get_goal!(456)
      ** (Ecto.NoResultsError)

  """
  def get_goal!(id), do: Repo.get!(Goal, id) |> Repo.preload([:account])

  @doc """
  Creates a goal.

  ## Examples

      iex> create_goal(%User{}, %{field: value})
      {:ok, %Goal{}}

      iex> create_goal(%User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_goal(user = %User{}, attrs \\ %{}) do
    goal =
      user
      |> Ecto.build_assoc(:goals)
      |> Goal.changeset(attrs)
      |> Repo.insert()

    case goal do
      {:ok, goal} -> {:ok, goal |> Repo.preload([:account])}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Updates a goal.

  ## Examples

      iex> update_goal(goal, %{field: new_value})
      {:ok, %Goal{}}

      iex> update_goal(goal, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_goal(%Goal{} = goal, attrs) do
    goal
    |> Goal.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a goal.

  ## Examples

      iex> delete_goal(goal)
      {:ok, %Goal{}}

      iex> delete_goal(goal)
      {:error, %Ecto.Changeset{}}

  """
  def delete_goal(%Goal{} = goal) do
    Repo.delete(goal)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking goal changes.

  ## Examples

      iex> change_goal(goal)
      %Ecto.Changeset{data: %Goal{}}

  """
  def change_goal(%Goal{} = goal, attrs \\ %{}) do
    Goal.changeset(goal, attrs)
  end
end
