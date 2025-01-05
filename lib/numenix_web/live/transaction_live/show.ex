defmodule NumenixWeb.TransactionLive.Show do
  use NumenixWeb, :live_view

  alias Numenix.Transactions
  alias Numenix.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Transaction {@transaction.id}
      <:subtitle>This is a transaction record from your database.</:subtitle>
      <:actions>
        <.link patch={~p"/transactions/#{@transaction}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit transaction</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Date">{@transaction.date}</:item>
      <:item title="Description">{@transaction.description}</:item>
      <:item title="Amount">{@transaction.amount}</:item>
      <:item title="Account balance">{@transaction.account_balance}</:item>
      <:item title="Category">{@transaction.category.name}</:item>
    </.list>

    <.back navigate={~p"/transactions"}>Back to transactions</.back>

    <.modal
      :if={@live_action == :edit}
      id="transaction-modal"
      show
      on_cancel={JS.patch(~p"/transactions/#{@transaction}")}
    >
      <.live_component
        module={NumenixWeb.TransactionLive.FormComponent}
        id={@transaction.id}
        title={@page_title}
        action={@live_action}
        transaction={@transaction}
        type_id={@transaction.type_id}
        categories={
          @categories
          |> Enum.filter(&(&1.type_id == @transaction.type_id))
        }
        current_user={@current_user}
        accounts={@accounts}
        patch={~p"/transactions/#{@transaction}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    {:ok,
     socket
     |> assign(:accounts, Accounts.list_accounts(user))
     |> assign(:categories, Transactions.list_categories(user))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:transaction, Transactions.get_transaction!(id))}
  end

  defp page_title(:show), do: "Show Transaction"
  defp page_title(:edit), do: "Edit Transaction"
end
