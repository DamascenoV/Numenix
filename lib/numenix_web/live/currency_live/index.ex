defmodule NumenixWeb.CurrencyLive.Index do
  use NumenixWeb, :live_view

  alias Numenix.Currencies
  alias Numenix.Currencies.Currency

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Currencies
      <:actions>
        <.link patch={~p"/currencies/new"}>
          <.button>New Currency</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="currencies"
      rows={@streams.currencies}
      row_click={fn {_id, currency} -> JS.navigate(~p"/currencies/#{currency}") end}
    >
      <:col :let={{_id, currency}} label="Name">{currency.name}</:col>
      <:col :let={{_id, currency}} label="Symbol">{currency.symbol}</:col>
      <:action :let={{_id, currency}}>
        <div class="sr-only">
          <.link navigate={~p"/currencies/#{currency}"}>Show</.link>
        </div>
        <.link patch={~p"/currencies/#{currency}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, currency}}>
        <.link
          phx-click={JS.push("delete", value: %{id: currency.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="currency-modal"
      show
      on_cancel={JS.patch(~p"/currencies")}
    >
      <.live_component
        module={NumenixWeb.CurrencyLive.FormComponent}
        id={@currency.id || :new}
        title={@page_title}
        action={@live_action}
        currency={@currency}
        current_user={@current_user}
        patch={~p"/currencies"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :currencies, Currencies.list_currencies(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Currency")
    |> assign(:currency, Currencies.get_currency!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Currency")
    |> assign(:currency, %Currency{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Currencies")
    |> assign(:currency, nil)
  end

  @impl true
  def handle_info({NumenixWeb.CurrencyLive.FormComponent, {:saved, currency}}, socket) do
    {:noreply, stream_insert(socket, :currencies, currency)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    currency = Currencies.get_currency!(id)
    {:ok, _} = Currencies.delete_currency(currency)

    {:noreply, stream_delete(socket, :currencies, currency)}
  end
end
