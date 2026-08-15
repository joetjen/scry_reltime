# Changelog

## [Unreleased]

### Added

- The `relational` + `time-series` composite kind -- a thin delegate, not a fused executor: `Scry.Reltime.parse/1`/`Scry.Reltime.Executor.run/5` both call straight through to `Scry.TimeSeries.parse/1`/`Scry.TimeSeries.Executor.run/5`. `relational` is a degenerate kind (no EP1/EP2 grammar/execution vocabulary of its own) and `Scry.TimeSeries.Executor.run/5` already lowers every `LAST` occurrence anywhere in a query's own tree -- including inside a nested/correlated `SELECT` body item, recursively -- into an ordinary `WHERE` predicate before `Scry.Core.Executor.run/4`'s own fully generic correlation/`WITH`/combinator machinery ever sees the tree. There is nothing left to build.
  Confirmed with a real end-to-end test, not just asserted from reading the code: a relational-shaped correlated nested `SELECT` (Scry's own `JOIN` equivalent, `SELECT events LAST 1h OF timestamp WHERE user_id = users.id { id }` nested inside `SELECT users { name, ... }`) composes correctly with `LAST`, executed against `scry_engine_inmemory` (a real, kind-independent `Scry.Core.EngineBehaviour` implementation with no native query language of its own to translate into) -- proof that `Scry.Core.QueryOps`'s own toolkit does the real work, not any engine-side cleverness.
  `test/scry/reltime_test.exs`.
