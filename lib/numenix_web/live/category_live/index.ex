defmodule NumenixWeb.CategoryLive.Index do
  use NumenixWeb, :live_view

  alias Numenix.Transactions
  alias Numenix.Transactions.Category

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Categories
      <:actions>
        <.link patch={~p"/categories/new"}>
          <.button>New Category</.button>
        </.link>
      </:actions>
    </.header>

    <Flop.Phoenix.table
      id="categories"
      items={@streams.categories}
      meta={@meta}
      path={~p"/categories"}
    >
      <:col :let={{_id, category}} label="Name" field={:name}>{category.name}</:col>
      <:col :let={{_id, category}} label="Type" field={:type_name}>{category.type.name}</:col>
      <:col :let={{id, category}}>
        <.link navigate={~p"/categories/#{category}"}>Show</.link>
        <.link patch={~p"/categories/#{category}/edit"}>Edit</.link>
        <.link
          phx-click={JS.push("delete", value: %{id: category.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:col>
    </Flop.Phoenix.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="category-modal"
      show
      on_cancel={JS.patch(~p"/categories")}
    >
      <.live_component
        module={NumenixWeb.CategoryLive.FormComponent}
        id={@category.id || :new}
        title={@page_title}
        action={@live_action}
        category={@category}
        current_user={@current_user}
        types={@types}
        patch={~p"/categories"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    case fetch_categories(socket.assigns.current_user, params) do
      {:ok, meta} ->
        {:ok,
         socket
         |> assign(:types, Transactions.list_types())
         |> assign(:meta, meta)}

      {:error, _reason} ->
        {:ok, redirect(socket, to: ~p"/categories")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Category")
    |> assign(:category, Transactions.get_category!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, %Category{})
  end

  defp apply_action(socket, :index, params) do
    case fetch_categories(socket.assigns.current_user, params) do
      {:ok, {categories, meta}} ->
        socket
        |> stream(:categories, categories, reset: true)
        |> assign(:page_title, "Listing Categories")
        |> assign(:types, Transactions.list_types())
        |> assign(:meta, meta)
    end
  end

  @impl true
  def handle_info({NumenixWeb.CategoryLive.FormComponent, {:saved, category}}, socket) do
    {:noreply, stream_insert(socket, :categories, category)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Transactions.get_category!(id)
    {:ok, _} = Transactions.delete_category(category)

    {:noreply, stream_delete(socket, :categories, category)}
  end

  defp fetch_categories(current_user, params) do
    case Transactions.list_categories(current_user, params) do
      {:ok, {categories, meta}} -> {:ok, {categories, meta}}
      {:error, reason} -> {:error, reason}
    end
  end
end
