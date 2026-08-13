defmodule Scry.Reltime.MixProject do
  use Mix.Project

  @version "0.1.0"

  # `mix precommit` includes `test` as a step; without this, Mix runs
  # the whole alias chain (including `mix test`) in :dev, and `mix test`
  # itself refuses to run outside :test when invoked as a sub-task
  # rather than the top-level command.
  def cli do
    [preferred_envs: [precommit: :test]]
  end

  def project do
    [
      app: :scry_reltime,
      version: @version,
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Scry.Reltime",
      docs: docs(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # === SCRY CORE / SCRY TIME-SERIES ===
      # Local path dependencies, not Hex version constraints, since
      # neither is published to Hex yet. Both real, not test-only:
      # Scry.Reltime.parse/1 and Scry.Reltime.Executor.run/5 both
      # delegate straight to scry_time_series's own equivalents --
      # `relational` is a degenerate kind (§2: no grammar/execution
      # vocabulary of its own), so this composite's own grammar is
      # exactly scry_time_series's own, with nothing added.
      {:scry_core, path: "../scry_core"},
      {:scry_time_series, path: "../scry_time_series"},

      # === SCRY ENGINE (test-only, proof vehicle) ===
      # scry_engine_inmemory is a real, kind-independent
      # Scry.Core.EngineBehaviour implementation with no native query
      # language of its own to translate into -- the right fixture to
      # *prove* (not just assert) that a relational-shaped nested-SELECT
      # correlation composes correctly with LAST, since any test
      # passing against it demonstrates Scry.Core.QueryOps's own
      # toolkit is doing the real work, not engine-side cleverness.
      {:scry_engine_inmemory, path: "../scry_engine_inmemory", only: :test},

      # === CODE QUALITY & STATIC ANALYSIS ===
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.14", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: [:dev, :test], runtime: false},
      # Credo is invoked via `MIX_ENV=test mix credo`
      # Dialyzer is invoked via `MIX_ENV=test mix dialyzer`
      # Sobelow is invoked via `MIX_ENV=test mix sobelow`
      # Coveralls is invoked via `MIX_ENV=test mix coveralls

      # === TESTING ===
      {:stream_data, "~> 1.1", only: [:dev, :test]},

      # === DEVELOPMENT TOOLING ===
      # Mix, and Hex are built-in (no deps needed)
      {:ex_doc, "~> 0.40", only: [:dev], runtime: false}
      # ExDoc is invoked via `MIX_ENV=dev mix docs`
    ]
  end

  # Fast/cheap checks first so a broken commit fails quickly; dialyzer
  # (slowest, especially its first PLT build) runs last.
  defp aliases do
    [
      precommit: [
        "format",
        "compile --warnings-as-errors",
        "credo --strict",
        "sobelow",
        "test",
        "dialyzer"
      ]
    ]
  end

  defp description do
    "The relational + time-series composite kind for Scry (impl_spec.md §2/§6) -- a " <>
      "thin delegate to scry_time_series (relational contributes no grammar/execution " <>
      "vocabulary of its own), with a real end-to-end test proving nested-SELECT " <>
      "correlation composes correctly with LAST, not just asserting it does."
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/joetjen/scry_reltime"},
      files: ~w(lib .formatter.exs mix.exs README.md CHANGELOG.md LICENSE)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: "https://github.com/joetjen/scry_reltime",
      source_ref: "v#{@version}",
      extras: extras()
    ]
  end

  defp extras do
    [
      "README.md",
      "CHANGELOG.md",
      "LICENSE"
    ]
  end
end
