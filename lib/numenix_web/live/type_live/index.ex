defmodule NumenixWeb.TypeLive.Index do
  use NumenixWeb, :live_view

  alias Numenix.Transactions

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Types
    </.header>

    <.table id="types" rows={@streams.types}>
      <:col :let={{_id, type}} label="Name">{type.name}</:col>
      <:col :let={{_id, type}} label="Subtraction">{type.subtraction}</:col>
    </.table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :types, Transactions.list_types())}
  end
end
