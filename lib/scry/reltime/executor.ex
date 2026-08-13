defmodule Scry.Reltime.Executor do
  @moduledoc """
  A direct delegation to `Scry.TimeSeries.Executor.run/5` -- see
  `Scry.Reltime`'s own moduledoc for why this composite needs no
  execution logic of its own at all.
  """

  alias Scry.Core.{CombinedQuery, Cursor, Query}

  @doc """
  Identical to `Scry.TimeSeries.Executor.run/5` -- lowers every `LAST`
  occurrence anywhere in `query_or_combined`'s own tree (including
  inside a nested/correlated `SELECT`, recursively) into an ordinary
  predicate, then delegates to `Scry.Core.Executor.run/4` for
  everything else (correlation, `WITH`, combinators, `GROUP BY`,
  sorting, projection -- core's own fully generic machinery).
  """
  @spec run(Query.t() | CombinedQuery.t(), module(), term(), map(), DateTime.t()) ::
          {:ok, Cursor.t()} | {:error, term()}
  def run(query_or_combined, engine_module, conn, params \\ %{}, now \\ DateTime.utc_now()) do
    Scry.TimeSeries.Executor.run(query_or_combined, engine_module, conn, params, now)
  end
end
