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

    <Flop.Phoenix.table id="account" items={@streams.accounts} meta={@meta} path={~p"/accounts"}>
      <:col :let={{_id, account}} label="Name" field={:name}>{account.name}</:col>
      <:col :let={{_id, account}} label="Balance" field={:balance}>{account.balance}</:col>
      <:col :let={{_id, account}} label="Currency" field={:currency}>{account.currency.symbol}</:col>
      <:col :let={{id, account}}>
        <.link navigate={~p"/accounts/#{account}"}>Show</.link>
        <.link patch={~p"/accounts/#{account}/edit"}>Edit</.link>
        <.link
          phx-click={JS.push("delete", value: %{id: account.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:col>
    </Flop.Phoenix.table>

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
  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    case fetch_accounts(user, params) do
      {:ok, meta} ->
        {:ok,
         socket
         |> assign(:currencies, Numenix.Currencies.list_currencies(user))
         |> assign(:meta, meta)}

      {:error, _reason} ->
        {:ok, redirect(socket, to: ~p"/accounts")}
    end
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

  defp apply_action(socket, :index, params) do
    user = socket.assigns.current_user

    case fetch_accounts(user, params) do
      {:ok, {accounts, meta}} ->
        socket
        |> stream(:accounts, accounts, reset: true)
        |> assign(:page_title, "Listing Accounts")
        |> assign(:currencies, Numenix.Currencies.list_currencies(user))
        |> assign(:meta, meta)
    end
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

  defp fetch_accounts(current_user, params) do
    case Numenix.Accounts.list_accounts(current_user, params) do
      {:ok, {accounts, meta}} -> {:ok, {accounts, meta}}
      {:error, reason} -> {:error, reason}
    end
  end
end
