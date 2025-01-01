defmodule Numenix.Currencies do
  @moduledoc """
  The Currencies context.
  """

  import Ecto.Query, warn: false
  alias Numenix.Repo

  alias Numenix.Currencies.Currency
  alias Numenix.Users.User

  @doc """
  Returns the list of currencies of the User.

  ## Examples

      iex> list_currencies(%User{})
      [%Currency{}, ...]

  """
  def list_currencies(user = %User{}) do
    Repo.all(from c in Currency, where: c.user_id == ^user.id)
  end

  @doc """
  Gets a single currency.

  Raises `Ecto.NoResultsError` if the Currency does not exist.

  ## Examples

      iex> get_currency!(123)
      %Currency{}

      iex> get_currency!(456)
      ** (Ecto.NoResultsError)

  """
  def get_currency!(id), do: Repo.get!(Currency, id, preload: :users)

  @doc """
  Creates a currency.

  ## Examples

      iex> create_currency(%User{}, %{field: value})
      {:ok, %Currency{}}

      iex> create_currency(%User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_currency(user = %User{}, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:currencies)
    |> Currency.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a currency.

  ## Examples

      iex> update_currency(currency, %{field: new_value})
      {:ok, %Currency{}}

      iex> update_currency(currency, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_currency(%Currency{} = currency, attrs) do
    currency
    |> Currency.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a currency.

  ## Examples

      iex> delete_currency(currency)
      {:ok, %Currency{}}

      iex> delete_currency(currency)
      {:error, %Ecto.Changeset{}}

  """
  def delete_currency(%Currency{} = currency) do
    Repo.delete(currency)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking currency changes.

  ## Examples

      iex> change_currency(currency)
      %Ecto.Changeset{data: %Currency{}}

  """
  def change_currency(%Currency{} = currency, attrs \\ %{}) do
    Currency.changeset(currency, attrs)
  end
end
