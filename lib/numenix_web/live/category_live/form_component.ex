defmodule NumenixWeb.CategoryLive.FormComponent do
  use NumenixWeb, :live_component

  alias Numenix.Transactions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage category records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="category-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input
          field={@form[:type_id]}
          type="select"
          label="Type"
          options={@types |> Enum.map(&{&1.name, &1.id})}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Category</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{category: category} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Transactions.change_category(category))
     end)}
  end

  @impl true
  def handle_event("validate", %{"category" => category_params}, socket) do
    changeset = Transactions.change_category(socket.assigns.category, category_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"category" => category_params}, socket) do
    save_category(socket, socket.assigns.action, category_params)
  end

  defp save_category(socket, :edit, category_params) do
    case Transactions.update_category(socket.assigns.category, category_params) do
      {:ok, category} ->
        notify_parent({:saved, category})

        {:noreply,
         socket
         |> put_flash(:info, "Category updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_category(socket, :new, category_params) do
    case Transactions.create_category(socket.assigns.current_user, category_params) do
      {:ok, category} ->
        notify_parent({:saved, category})

        {:noreply,
         socket
         |> put_flash(:info, "Category created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
