defmodule NumenixWeb.GoalLive.Index do
  use NumenixWeb, :live_view

  alias Numenix.Accounts
  alias Numenix.Accounts.Goal

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Goals
      <:actions>
        <.link patch={~p"/goals/new"}>
          <.button>New Goal</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="goals"
      rows={@streams.goals}
      row_click={fn {_id, goal} -> JS.navigate(~p"/goals/#{goal}") end}
    >
      <:col :let={{_id, goal}} label="Account">{goal.account.name}</:col>
      <:col :let={{_id, goal}} label="Name">{goal.name}</:col>
      <:col :let={{_id, goal}} label="Description">{goal.description}</:col>
      <:col :let={{_id, goal}} label="Amount">{goal.amount}</:col>
      <:col :let={{_id, goal}} label="Done">{goal.done}</:col>
      <:action :let={{_id, goal}}>
        <div class="sr-only">
          <.link navigate={~p"/goals/#{goal}"}>Show</.link>
        </div>
        <.link patch={~p"/goals/#{goal}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, goal}}>
        <.link
          phx-click={JS.push("delete", value: %{id: goal.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal :if={@live_action in [:new, :edit]} id="goal-modal" show on_cancel={JS.patch(~p"/goals")}>
      <.live_component
        module={NumenixWeb.GoalLive.FormComponent}
        id={@goal.id || :new}
        title={@page_title}
        action={@live_action}
        goal={@goal}
        accounts={@accounts}
        current_user={@current_user}
        patch={~p"/goals"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:goals, Accounts.list_goals(socket.assigns.current_user))
     |> assign(:accounts, Accounts.list_account(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Goal")
    |> assign(:goal, Accounts.get_goal!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Goal")
    |> assign(:goal, %Goal{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Goals")
    |> assign(:goal, nil)
  end

  @impl true
  def handle_info({NumenixWeb.GoalLive.FormComponent, {:saved, goal}}, socket) do
    {:noreply, stream_insert(socket, :goals, goal)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    goal = Accounts.get_goal!(id)
    {:ok, _} = Accounts.delete_goal(goal)

    {:noreply, stream_delete(socket, :goals, goal)}
  end
end
