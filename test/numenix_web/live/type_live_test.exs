defmodule NumenixWeb.TypeLiveTest do
  use NumenixWeb.ConnCase

  import Phoenix.LiveViewTest
  import Numenix.TransactionsFixtures
  import Numenix.UsersFixtures

  defp create_type(_) do
    type = type_fixture()
    %{type: type}
  end

  describe "Index" do
    setup [:create_type]

    test "lists all types", %{conn: conn, type: type} do
      {:ok, _index_live, html} = live(conn |> log_in_user(user_fixture()), ~p"/types")

      assert html =~ "Listing Types"
      assert html =~ type.name
    end
  end
end
