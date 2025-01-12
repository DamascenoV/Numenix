defmodule NumenixWeb.TypeLive.Index do
  use NumenixWeb, :live_view

  alias Numenix.Transactions

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Types
    </.header>

    <Flop.Phoenix.table id="types" items={@streams.types} meta={@meta} path={~p"/types"}>
      <:col :let={{_id, type}} label="Name" field={:name}>{type.name}</:col>
      <:col :let={{_id, type}} label="Subtraction" field={:subtraction}>{type.subtraction}</:col>
    </Flop.Phoenix.table>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    case fetch_types(params) do
      {:ok, {_types, meta}} ->
        {:ok,
         socket
         |> stream(:types, %{})
         |> assign(:meta, meta)}

      {:error, _} ->
        {:ok, redirect(socket, ~p"/types")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    case fetch_types(params) do
      {:ok, {types, meta}} ->
        {:noreply,
         socket
         |> stream(:types, types, reset: true)
         |> assign(:meta, meta)}
    end
  end

  defp fetch_types(params) do
    case Transactions.list_types(params) do
      {:ok, {currencies, meta}} -> {:ok, {currencies, meta}}
      {:error, reason} -> {:error, reason}
    end
  end
end
