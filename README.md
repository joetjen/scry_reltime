# Scry.Reltime

The `relational` + `time-series` composite kind for Scry -- the canonical dependency
name for an application combining a
relational-shaped query (nested-`SELECT` correlation, Scry's own `JOIN` equivalent) with
`LAST <duration> OF <field>`/`rate(<duration>)`.

`relational` is a degenerate kind (no grammar of its own) and `LAST` already lowers into
an ordinary `WHERE` predicate, recursively, before any engine ever sees it -- so this
package is a thin delegate to `scry_time_series`, not a fused executor. See
`Scry.Reltime`'s own moduledoc, and `CHANGELOG.md`, for the full "what we confirmed,
not just assumed" reasoning.
