defmodule NumenixWeb.CurrencyLive.FormComponent do
  use NumenixWeb, :live_component

  alias Numenix.Currencies

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage currency records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="currency-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:symbol]} type="text" label="Symbol" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Currency</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{currency: currency} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Currencies.change_currency(currency))
     end)}
  end

  @impl true
  def handle_event("validate", %{"currency" => currency_params}, socket) do
    changeset = Currencies.change_currency(socket.assigns.currency, currency_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"currency" => currency_params}, socket) do
    save_currency(socket, socket.assigns.action, currency_params)
  end

  defp save_currency(socket, :edit, currency_params) do
    case Currencies.update_currency(socket.assigns.currency, currency_params) do
      {:ok, currency} ->
        notify_parent({:saved, currency})

        {:noreply,
         socket
         |> put_flash(:info, "Currency updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_currency(socket, :new, currency_params) do
    case Currencies.create_currency(socket.assigns.current_user, currency_params) do
      {:ok, currency} ->
        notify_parent({:saved, currency})

        {:noreply,
         socket
         |> put_flash(:info, "Currency created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
