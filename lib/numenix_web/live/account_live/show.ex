defmodule NumenixWeb.AccountLive.Show do
  use NumenixWeb, :live_view

  alias Numenix.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Account {@account.id}
      <:subtitle>This is a account record from your database.</:subtitle>
      <:actions>
        <.link patch={~p"/accounts/#{@account}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit account</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Name">{@account.name}</:item>
      <:item title="Balance">{@account.balance}</:item>
    </.list>

    <.back navigate={~p"/accounts"}>Back to account</.back>

    <.modal
      :if={@live_action == :edit}
      id="account-modal"
      show
      on_cancel={JS.patch(~p"/accounts/#{@account}")}
    >
      <.live_component
        module={NumenixWeb.AccountLive.FormComponent}
        id={@account.id}
        title={@page_title}
        action={@live_action}
        account={@account}
        currencies={@currencies}
        patch={~p"/accounts/#{@account}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:currencies, Numenix.Currencies.list_currencies(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:account, Accounts.get_account!(id))}
  end

  defp page_title(:show), do: "Show Account"
  defp page_title(:edit), do: "Edit Account"
end
