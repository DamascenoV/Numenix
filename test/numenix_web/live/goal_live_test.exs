defmodule NumenixWeb.GoalLiveTest do
  use NumenixWeb.ConnCase

  import Phoenix.LiveViewTest
  import Numenix.AccountsFixtures
  import Numenix.CurrenciesFixtures
  import Numenix.UsersFixtures

  @create_attrs %{name: "some name", done: true, description: "some description", amount: "120.5"}
  @update_attrs %{name: "some updated name", done: false, description: "some updated description", amount: "456.7"}
  @invalid_attrs %{name: nil, done: false, description: nil, amount: nil}

  defp create_goal(_) do
    user = user_fixture()
    currency = currency_fixture(user)
    account = account_fixture(user, %{currency_id: currency.id})
    goal = goal_fixture(user, %{account_id: account.id})
    %{goal: goal, user: user}
  end

  describe "Index" do
    setup [:create_goal]

    test "lists all goals", %{conn: conn, goal: goal, user: user} do
      {:ok, _index_live, html} = live(conn |> log_in_user(user), ~p"/goals")

      assert html =~ "Listing Goals"
      assert html =~ goal.name
    end

    test "saves new goal", %{conn: conn, user: user} do
      {:ok, index_live, _html} = live(conn |> log_in_user(user), ~p"/goals")

      assert index_live |> element("a", "New Goal") |> render_click() =~
               "New Goal"

      assert_patch(index_live, ~p"/goals/new")

      assert index_live
             |> form("#goal-form", goal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#goal-form", goal: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/goals")

      html = render(index_live)
      assert html =~ "Goal created successfully"
      assert html =~ "some name"
    end

    test "updates goal in listing", %{conn: conn, goal: goal, user: user} do
      {:ok, index_live, _html} = live(conn |> log_in_user(user), ~p"/goals")

      assert index_live |> element("#goals-#{goal.id} a", "Edit") |> render_click() =~
               "Edit Goal"

      assert_patch(index_live, ~p"/goals/#{goal}/edit")

      assert index_live
             |> form("#goal-form", goal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#goal-form", goal: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/goals")

      html = render(index_live)
      assert html =~ "Goal updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes goal in listing", %{conn: conn, goal: goal, user: user} do
      {:ok, index_live, _html} = live(conn |> log_in_user(user), ~p"/goals")

      assert index_live |> element("#goals-#{goal.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#goals-#{goal.id}")
    end
  end

  describe "Show" do
    setup [:create_goal]

    test "displays goal", %{conn: conn, goal: goal, user: user} do
      {:ok, _show_live, html} = live(conn |> log_in_user(user), ~p"/goals/#{goal}")

      assert html =~ "Show Goal"
      assert html =~ goal.name
    end

    test "updates goal within modal", %{conn: conn, goal: goal, user: user} do
      {:ok, show_live, _html} = live(conn |> log_in_user(user), ~p"/goals/#{goal}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Goal"

      assert_patch(show_live, ~p"/goals/#{goal}/show/edit")

      assert show_live
             |> form("#goal-form", goal: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#goal-form", goal: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/goals/#{goal}")

      html = render(show_live)
      assert html =~ "Goal updated successfully"
      assert html =~ "some updated name"
    end
  end
end
