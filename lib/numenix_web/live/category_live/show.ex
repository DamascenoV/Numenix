defmodule NumenixWeb.CategoryLive.Show do
  use NumenixWeb, :live_view

  alias Numenix.Transactions

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Category {@category.id}
      <:subtitle>This is a category record from your database.</:subtitle>
      <:actions>
        <.link patch={~p"/categories/#{@category}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit category</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Name">{@category.name}</:item>
    </.list>

    <.back navigate={~p"/categories"}>Back to categories</.back>

    <.modal
      :if={@live_action == :edit}
      id="category-modal"
      show
      on_cancel={JS.patch(~p"/categories/#{@category}")}
    >
      <.live_component
        module={NumenixWeb.CategoryLive.FormComponent}
        id={@category.id}
        title={@page_title}
        action={@live_action}
        category={@category}
        patch={~p"/categories/#{@category}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:category, Transactions.get_category!(id))}
  end

  defp page_title(:show), do: "Show Category"
  defp page_title(:edit), do: "Edit Category"
end
