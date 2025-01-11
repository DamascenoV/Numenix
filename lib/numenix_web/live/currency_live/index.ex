defmodule NumenixWeb.CurrencyLive.Index do
  use NumenixWeb, :live_view
  alias Numenix.Currencies
  alias Numenix.Currencies.Currency
  alias Phoenix.LiveView.JS

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

    <Flop.Phoenix.table
      id="currencies"
      items={@streams.currencies}
      meta={@meta}
      path={~p"/currencies"}
    >
      <:col :let={{_id, currency}} label="Name" field={:name}>{currency.name}</:col>
      <:col :let={{_id, currency}} label="Symbol" field={:symbol}>{currency.symbol}</:col>
      <:col :let={{id, currency}} label="Actions">
        <.link navigate={~p"/currencies/#{currency}"}>Show</.link>
        <.link patch={~p"/currencies/#{currency}/edit"}>Edit</.link>
        <.link
          phx-click={JS.push("delete", value: %{id: currency.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:col>
    </Flop.Phoenix.table>

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
  def mount(params, _session, socket) do
    case fetch_currencies(socket.assigns.current_user, params) do
      {:ok, meta} ->
        {:ok, socket |> stream(:currencies, %{}) |> assign(:meta, meta)}

      {:error, _reason} ->
        {:ok, redirect(socket, to: ~p"/currencies")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info({NumenixWeb.CurrencyLive.FormComponent, {:saved, currency}}, socket) do
    {:noreply, stream_insert(socket, :currencies, currency)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    with currency <- Currencies.get_currency!(id),
         {:ok, _deleted} <- Currencies.delete_currency(currency) do
      {:noreply, stream_delete(socket, :currencies, currency)}
    else
      {:error, error} ->
        {:noreply,
         put_flash(
           socket,
           :error,
           Ecto.Changeset.traverse_errors(error, fn {msg, _opts} -> msg end)
           |> Enum.map(fn {_key, value} -> List.first(value) end)
           |> List.first()
         )}
    end
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

  defp apply_action(socket, :index, params) do
    case fetch_currencies(socket.assigns.current_user, params) do
      {:ok, {currencies, meta}} ->
        socket
        |> assign(:page_title, "Listing Currencies")
        |> stream(:currencies, currencies, reset: true)
        |> assign(:meta, meta)

      {:error, _reason} ->
        redirect(socket, to: ~p"/currencies")
    end
  end

  defp fetch_currencies(current_user, params) do
    case Currencies.list_currencies(current_user, params) do
      {:ok, {currencies, meta}} -> {:ok, {currencies, meta}}
      {:error, reason} -> {:error, reason}
    end
  end
end
