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

    <.table
      id="categories"
      rows={@streams.categories}
      row_click={fn {_id, category} -> JS.navigate(~p"/categories/#{category}") end}
    >
      <:col :let={{_id, category}} label="Name">{category.name}</:col>
      <:col :let={{_id, category}} label="Type">{category.type.name}</:col>
      <:action :let={{_id, category}}>
        <div class="sr-only">
          <.link navigate={~p"/categories/#{category}"}>Show</.link>
        </div>
        <.link patch={~p"/categories/#{category}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, category}}>
        <.link
          phx-click={JS.push("delete", value: %{id: category.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

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
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:categories, Transactions.list_categories(socket.assigns.current_user))
     |> assign(:types, Transactions.list_types())}
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

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Categories")
    |> assign(:category, nil)
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
end
