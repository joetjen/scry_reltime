defmodule Scry.Reltime do
  @moduledoc """
  The `relational` + `time-series` composite kind for Scry --
  `SELECT users WHERE age > 30 { name, SELECT events LAST 1h OF
  timestamp { id } }`, a relational-shaped nested-`SELECT` correlation
  (Scry's own `JOIN` equivalent) alongside `LAST`/`rate(<duration>)`.

  **A thin delegate, not a fused executor** -- unlike `scry_docgraph`
  (document + graph both bypass `Scry.Core.EngineBehaviour` with their
  own bespoke, whole-space-needing executors, so composing them for
  real needs a genuinely new dispatcher recognizing both kinds' own
  `{:variant, ...}` tags), `relational` is a *degenerate* kind (§2: no
  EP1/EP2 grammar or execution vocabulary of its own at all), and
  `Scry.TimeSeries.Executor.run/5` already lowers every `LAST`
  occurrence anywhere in a query's own tree -- including inside a
  nested/correlated `SELECT` body item, recursively, `Scry.TimeSeries.
  Executor`'s own moduledoc has the full mechanics -- into an ordinary
  `WHERE` predicate *before* `Scry.Core.Executor.run/4` (core's own
  fully generic correlation/`WITH`/combinator machinery) ever sees the
  tree. There is nothing left for this package to add: this composite's
  real value already exists with zero new code, confirmed with a real
  end-to-end test against `scry_engine_inmemory` (this package's own
  `CHANGELOG.md` has the full "what we proved, not just assumed" story),
  not just assumed.

  `parse/1` mirrors `Scry.TimeSeries.parse/1` (there is no grammar
  fragment of this package's own to compose in); use `Scry.TimeSeries.
  Executor.run/5` directly to execute what it returns.
  """

  alias Scry.Core.{CombinedQuery, Query}

  @doc """
  Parses `source` (Scry query text) into a `%Scry.Core.Query{}` (or a
  `%Scry.Core.CombinedQuery{}`) -- a direct delegation to `Scry.
  TimeSeries.parse/1`, since this composite has no grammar fragment of
  its own: `relational` contributes nothing syntactically, so the
  merged grammar `scry_time_series` already ships *is* this composite's
  own grammar, unchanged.
  """
  @spec parse(String.t()) :: {:ok, Query.t() | CombinedQuery.t()} | {:error, term()}
  def parse(source) when is_binary(source) do
    Scry.TimeSeries.parse(source)
  end
end
