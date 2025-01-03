defmodule NumenixWeb.GoalLive.Show do
  use NumenixWeb, :live_view

  alias Numenix.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Goal {@goal.id}
      <:subtitle>This is a goal record from your database.</:subtitle>
      <:actions>
        <.link patch={~p"/goals/#{@goal}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit goal</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Name">{@goal.name}</:item>
      <:item title="Description">{@goal.description}</:item>
      <:item title="Amount">{@goal.amount}</:item>
      <:item title="Done">{@goal.done}</:item>
    </.list>

    <.back navigate={~p"/goals"}>Back to goals</.back>

    <.modal :if={@live_action == :edit} id="goal-modal" show on_cancel={JS.patch(~p"/goals/#{@goal}")}>
      <.live_component
        module={NumenixWeb.GoalLive.FormComponent}
        id={@goal.id}
        title={@page_title}
        action={@live_action}
        goal={@goal}
        accounts={@accounts}
        patch={~p"/goals/#{@goal}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:accounts, Accounts.list_account(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:goal, Accounts.get_goal!(id))}
  end

  defp page_title(:show), do: "Show Goal"
  defp page_title(:edit), do: "Edit Goal"
end
