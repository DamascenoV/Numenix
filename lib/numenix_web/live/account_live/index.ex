defmodule NumenixWeb.AccountLive.Index do
  use NumenixWeb, :live_view

  alias Numenix.Accounts
  alias Numenix.Accounts.Account

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Account
      <:actions>
        <.link patch={~p"/accounts/new"}>
          <.button>New Account</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="account"
      rows={@streams.accounts}
      row_click={fn {_id, account} -> JS.navigate(~p"/accounts/#{account}") end}
    >
      <:col :let={{_id, account}} label="Name">{account.name}</:col>
      <:col :let={{_id, account}} label="Balance">{account.balance}</:col>
      <:col :let={{_id, account}} label="Currency">{account.currency.symbol}</:col>
      <:action :let={{_id, account}}>
        <div class="sr-only">
          <.link navigate={~p"/accounts/#{account}"}>Show</.link>
        </div>
        <.link patch={~p"/accounts/#{account}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, account}}>
        <.link
          phx-click={JS.push("delete", value: %{id: account.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="account-modal"
      show
      on_cancel={JS.patch(~p"/accounts")}
    >
      <.live_component
        module={NumenixWeb.AccountLive.FormComponent}
        id={@account.id || :new}
        title={@page_title}
        action={@live_action}
        account={@account}
        currencies={@currencies}
        current_user={@current_user}
        patch={~p"/accounts"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    {:ok,
     socket
     |> stream(:accounts, Accounts.list_account(user))
     |> assign(:currencies, Numenix.Currencies.list_currencies(user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Account")
    |> assign(:account, Accounts.get_account!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Account")
    |> assign(:account, %Account{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Account")
    |> assign(:account, nil)
  end

  @impl true
  def handle_info({NumenixWeb.AccountLive.FormComponent, {:saved, account}}, socket) do
    {:noreply, stream_insert(socket, :accounts, account)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    account = Accounts.get_account!(id)
    {:ok, _} = Accounts.delete_account(account)

    {:noreply, stream_delete(socket, :accounts, account)}
  end
end
