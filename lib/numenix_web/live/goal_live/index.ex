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

    <.filter_form
      id="goal_id"
      fields={[
        name: [
          label: gettext("Name"),
          op: :like,
          type: "text"
        ],
        description: [
          label: gettext("Description"),
          op: :like,
          type: "text"
        ],
        amount: [
          label: gettext("Amount"),
          op: :==,
          type: "number"
        ],
        done: [
          label: gettext("Done"),
          op: :==,
          type: "checkbox"
        ]
      ]}
      meta={@meta}
    />

    <Flop.Phoenix.table id="goals" items={@streams.goals} meta={@meta} path={~p"/goals"}>
      <:col :let={{_id, goal}} label="Account" field={:account}>{goal.account.name}</:col>
      <:col :let={{_id, goal}} label="Name" field={:name}>{goal.name}</:col>
      <:col :let={{_id, goal}} label="Description" field={:description}>{goal.description}</:col>
      <:col :let={{_id, goal}} label="Amount" field={:amount}>{goal.amount}</:col>
      <:col :let={{_id, goal}} label="Done" field={:done}>{goal.done}</:col>
      <:col :let={{id, goal}}>
        <.link navigate={~p"/goals/#{goal}"}>Show</.link>
        <.link patch={~p"/goals/#{goal}/edit"}>Edit</.link>
        <.link
          phx-click={JS.push("delete", value: %{id: goal.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:col>
    </Flop.Phoenix.table>

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
  def mount(params, _session, socket) do
    case Accounts.list_goals(socket.assigns.current_user, params) do
      {:ok, meta} ->
        {:ok,
         socket
         |> assign(:meta, meta)
         |> assign(:accounts, Accounts.list_accounts(socket.assigns.current_user))}

      {:error, _reason} ->
        {:ok, redirect(socket, to: ~p"/goals")}
    end
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

  defp apply_action(socket, :index, params) do
    case Accounts.list_goals(socket.assigns.current_user, params) do
      {:ok, {goals, meta}} ->
        socket
        |> stream(:goals, goals, reset: true)
        |> assign(:page_title, "Listing Goals")
        |> assign(:meta, meta)

      {:error, _reason} ->
        redirect(socket, to: ~p"/goals")
    end
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

  @impl true
  def handle_event("update-filter", params, socket) do
    params = Map.delete(params, "_target")
    {:noreply, apply_action(socket, :index, params)}
  end
end
