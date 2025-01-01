defmodule NumenixWeb.CurrencyLive.Show do
  use NumenixWeb, :live_view

  alias Numenix.Currencies

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Currency {@currency.id}
      <:subtitle>This is a currency record from your database.</:subtitle>
      <:actions>
        <.link patch={~p"/currencies/#{@currency}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit currency</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Name">{@currency.name}</:item>
      <:item title="Symbol">{@currency.symbol}</:item>
    </.list>

    <.back navigate={~p"/currencies"}>Back to currencies</.back>

    <.modal
      :if={@live_action == :edit}
      id="currency-modal"
      show
      on_cancel={JS.patch(~p"/currencies/#{@currency}")}
    >
      <.live_component
        module={NumenixWeb.CurrencyLive.FormComponent}
        id={@currency.id}
        title={@page_title}
        action={@live_action}
        currency={@currency}
        patch={~p"/currencies/#{@currency}"}
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
     |> assign(:currency, Currencies.get_currency!(id))}
  end

  defp page_title(:show), do: "Show Currency"
  defp page_title(:edit), do: "Edit Currency"
end
