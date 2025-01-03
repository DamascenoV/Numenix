defmodule NumenixWeb.GoalLive.FormComponent do
  use NumenixWeb, :live_component

  alias Numenix.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage goal records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="goal-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:amount]} type="number" label="Amount" step="any" />
        <.input field={@form[:done]} type="checkbox" label="Done" />
        <.input
          field={@form[:account_id]}
          type="select"
          label="Account"
          options={@accounts |> Enum.map(&{&1.name, &1.id})}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Goal</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{goal: goal} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Accounts.change_goal(goal))
     end)}
  end

  @impl true
  def handle_event("validate", %{"goal" => goal_params}, socket) do
    changeset = Accounts.change_goal(socket.assigns.goal, goal_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"goal" => goal_params}, socket) do
    save_goal(socket, socket.assigns.action, goal_params)
  end

  defp save_goal(socket, :edit, goal_params) do
    case Accounts.update_goal(socket.assigns.goal, goal_params) do
      {:ok, goal} ->
        notify_parent({:saved, goal})

        {:noreply,
         socket
         |> put_flash(:info, "Goal updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_goal(socket, :new, goal_params) do
    case Accounts.create_goal(socket.assigns.current_user, goal_params) do
      {:ok, goal} ->
        notify_parent({:saved, goal})

        {:noreply,
         socket
         |> put_flash(:info, "Goal created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
