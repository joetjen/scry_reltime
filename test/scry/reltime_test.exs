defmodule Scry.ReltimeTest do
  @moduledoc """
  The real proof this composite doesn't need a fused executor: a
  relational-shaped nested-`SELECT` correlation (Scry's own `JOIN`
  equivalent) combined with `LAST`, executed end to end against
  `scry_engine_inmemory` -- a real, kind-independent `Scry.Core.
  EngineBehaviour` implementation with no native query language of its
  own, so a passing test here demonstrates `Scry.Core.QueryOps`'s own
  toolkit is doing the real work, not anything engine-specific.
  """

  use ExUnit.Case, async: true

  alias Scry.Core.Cursor
  alias Scry.Engine.InMemory

  @now ~U[2026-08-13 10:30:00Z]

  @users [
    %{"id" => 1, "name" => "Alice"},
    %{"id" => 2, "name" => "Bob"}
  ]

  # event 100 (user 1): inside the trailing 1h window ([09:30, 10:30])
  # event 101 (user 1): years outside the window -- tests LAST actually
  # filters, not just that the query parses
  # event 102 (user 2): inside the window, correlated to a *different*
  # outer row than event 100 -- tests correlation ties each nested
  # result to its own outer row, not just that LAST filters globally
  @events [
    %{"id" => 100, "user_id" => 1, "timestamp" => ~U[2026-08-13 10:00:00Z]},
    %{"id" => 101, "user_id" => 1, "timestamp" => ~U[2020-01-01 00:00:00Z]},
    %{"id" => 102, "user_id" => 2, "timestamp" => ~U[2026-08-13 10:15:00Z]}
  ]

  defp conn do
    InMemory.Conn.new(%{
      ["users"] => @users,
      ["events"] => @events
    })
  end

  test "a relational-shaped correlated nested SELECT composes correctly with LAST" do
    {:ok, query} =
      Scry.Reltime.parse("""
      SELECT users ORDER BY id { name,
        SELECT events LAST 1h OF timestamp WHERE user_id = users.id { id }
      }
      """)

    assert {:ok, cursor} = Scry.Reltime.Executor.run(query, InMemory, conn(), %{}, @now)
    rows = Cursor.to_list(cursor)

    assert rows == [
             %{"name" => "Alice", "events" => [%{"id" => 100}]},
             %{"name" => "Bob", "events" => [%{"id" => 102}]}
           ]
  end

  test "an ordinary query with no LAST at all still works, unaffected" do
    {:ok, query} = Scry.Reltime.parse("SELECT users ORDER BY id { name }")
    assert {:ok, cursor} = Scry.Reltime.Executor.run(query, InMemory, conn())
    assert Cursor.to_list(cursor) == [%{"name" => "Alice"}, %{"name" => "Bob"}]
  end
end
