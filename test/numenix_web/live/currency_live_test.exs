defmodule NumenixWeb.CurrencyLiveTest do
  use NumenixWeb.ConnCase

  import Phoenix.LiveViewTest
  import Numenix.CurrenciesFixtures
  import Numenix.UsersFixtures

  @create_attrs %{name: "some name", symbol: "some symbol"}
  @update_attrs %{name: "some updated name", symbol: "some updated symbol"}
  @invalid_attrs %{name: nil, symbol: nil}

  defp create_currency(_) do
    user = user_fixture()
    currency = currency_fixture(user)
    %{currency: currency, user: user}
  end

  describe "Index" do
    setup [:create_currency]

    test "lists all currencies", %{conn: conn, currency: currency, user: user} do
      {:ok, _index_live, html} = live(conn |> log_in_user(user), ~p"/currencies")

      assert html =~ "Listing Currencies"
      assert html =~ currency.name
    end

    test "saves new currency", %{conn: conn, user: user} do
      {:ok, index_live, _html} = live(conn |> log_in_user(user), ~p"/currencies")

      assert index_live |> element("a", "New Currency") |> render_click() =~
               "New Currency"

      assert_patch(index_live, ~p"/currencies/new")

      assert index_live
             |> form("#currency-form", currency: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#currency-form", currency: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/currencies")

      html = render(index_live)
      assert html =~ "Currency created successfully"
      assert html =~ "some name"
    end

    test "updates currency in listing", %{conn: conn, currency: currency, user: user} do
      {:ok, index_live, _html} = live(conn |> log_in_user(user), ~p"/currencies")

      assert index_live |> element("#currencies-#{currency.id} a", "Edit") |> render_click() =~
               "Edit Currency"

      assert_patch(index_live, ~p"/currencies/#{currency}/edit")

      assert index_live
             |> form("#currency-form", currency: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#currency-form", currency: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/currencies")

      html = render(index_live)
      assert html =~ "Currency updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes currency in listing", %{conn: conn, currency: currency, user: user} do
      {:ok, index_live, _html} = live(conn |> log_in_user(user), ~p"/currencies")

      assert index_live |> element("#currencies-#{currency.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#currencies-#{currency.id}")
    end
  end

  describe "Show" do
    setup [:create_currency]

    test "displays currency", %{conn: conn, currency: currency, user: user} do
      {:ok, _show_live, html} = live(conn |> log_in_user(user), ~p"/currencies/#{currency}")

      assert html =~ "Show Currency"
      assert html =~ currency.name
    end

    test "updates currency within modal", %{conn: conn, currency: currency, user: user} do
      {:ok, show_live, _html} = live(conn |> log_in_user(user), ~p"/currencies/#{currency}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Currency"

      assert_patch(show_live, ~p"/currencies/#{currency}/show/edit")

      assert show_live
             |> form("#currency-form", currency: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#currency-form", currency: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/currencies/#{currency}")

      html = render(show_live)
      assert html =~ "Currency updated successfully"
      assert html =~ "some updated name"
    end
  end
end
