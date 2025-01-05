defmodule NumenixWeb.TransactionLive.Index do
  use NumenixWeb, :live_view

  alias Numenix.Transactions
  alias Numenix.Transactions.Transaction
  alias Numenix.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Transactions
      <:actions>
        <%= for type <- Transactions.list_types() do %>
          <.link patch={~p"/transactions/new?type=#{type.id}"}>
            <.button class="text-xs">New {type.name}</.button>
          </.link>
        <% end %>
      </:actions>
    </.header>

    <.table
      id="transactions"
      rows={@streams.transactions}
      row_click={fn {_id, transaction} -> JS.navigate(~p"/transactions/#{transaction}") end}
    >
      <:col :let={{_id, transaction}} label="Date">{transaction.date}</:col>
      <:col :let={{_id, transaction}} label="Description">{transaction.description}</:col>
      <:col :let={{_id, transaction}} label="Amount">{transaction.amount}</:col>
      <:col :let={{_id, transaction}} label="Account balance">{transaction.account_balance}</:col>
      <:col :let={{_id, transaction}} label="Category">{transaction.category.name}</:col>
      <:action :let={{_id, transaction}}>
        <div class="sr-only">
          <.link navigate={~p"/transactions/#{transaction}"}>Show</.link>
        </div>
        <.link patch={~p"/transactions/#{transaction}/edit?type=#{transaction.type_id}"}>Edit</.link>
      </:action>
      <:action :let={{id, transaction}}>
        <.link
          phx-click={JS.push("delete", value: %{id: transaction.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="transaction-modal"
      show
      on_cancel={JS.patch(~p"/transactions")}
    >
      <.live_component
        module={NumenixWeb.TransactionLive.FormComponent}
        id={@transaction.id || :new}
        title={@page_title}
        action={@live_action}
        transaction={@transaction}
        type_id={@type_id}
        categories={@categories}
        current_user={@current_user}
        accounts={@accounts}
        patch={~p"/transactions"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    {:ok,
     socket
     |> stream(:transactions, Transactions.list_transactions(user))
     |> assign(:accounts, Accounts.list_accounts(user))
     |> assign(:type_id, nil)
     |> assign(:categories, nil)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, params) do
    socket
    |> assign(:page_title, "Edit Transaction")
    |> assign(:transaction, Transactions.get_transaction!(params["id"]))
    |> assign(:accounts, Accounts.list_accounts(socket.assigns.current_user))
    |> assign(
      :categories,
      Transactions.list_categories(socket.assigns.current_user)
      |> Enum.filter(&(&1.type_id == params["type"]))
    )
    |> assign(:type_id, params["type"])
  end

  defp apply_action(socket, :new, params) do
    socket
    |> assign(:page_title, "New Transaction")
    |> assign(:transaction, %Transaction{})
    |> assign(:accounts, Accounts.list_accounts(socket.assigns.current_user))
    |> assign(
      :categories,
      Transactions.list_categories(socket.assigns.current_user)
      |> Enum.filter(&(&1.type_id == params["type"]))
    )
    |> assign(:type_id, params["type"])
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Transactions")
    |> assign(:transaction, nil)
  end

  @impl true
  def handle_info({NumenixWeb.TransactionLive.FormComponent, {:saved, transaction}}, socket) do
    {:noreply, stream_insert(socket, :transactions, transaction)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Transactions.get_transaction!(id)
    {:ok, _} = Transactions.delete_transaction(transaction)

    {:noreply, stream_delete(socket, :transactions, transaction)}
  end
end
