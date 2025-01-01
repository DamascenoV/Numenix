defmodule Numenix.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias Numenix.Repo

  alias Numenix.Users.User
  alias Numenix.Transactions.Type
  alias Numenix.Transactions.Category

  @doc """
  Returns the list of types.

  ## Examples

      iex> list_types()
      [%Type{}, ...]

  """
  def list_types do
    Repo.all(Type)
  end

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
end
