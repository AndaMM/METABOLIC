# Changelog
## Updated Sept 2026
This documents the changes made in this fork on top of upstream
[AnantharamanLab/METABOLIC](https://github.com/AnantharamanLab/METABOLIC), starting from the
last unmodified upstream commit (`3e6a73f`, Jan 2025). It covers `METABOLIC-C.pl`,
`METABOLIC-G.pl`, and `METABOLIC-C.2nd_run.pl` unless noted otherwise.

## GTDB-Tk decoupled from the pipeline
*(`METABOLIC-C.pl`, `METABOLIC-C.2nd_run.pl` — `METABOLIC-G.pl` never used GTDB-Tk)*

- Previously the scripts shelled out to `gtdbtk classify_wf` on the input genomes directly.
- GTDB-Tk is no longer invoked by these scripts. A new **required** `-gtdbtk-dir`/`-gtdb`
  option points at a GTDB-Tk `classify_wf` output directory computed beforehand; the script
  copies `gtdbtk.bac120.summary.tsv`/`gtdbtk.ar53.summary.tsv` from there.
- Missing `-gtdbtk-dir` now dies immediately with setup instructions instead of running
  GTDB-Tk in-process partway through the run.

## Configurable database directory (`-db-dir`)

- Previously all database paths were hardcoded to `$METABOLIC_dir` (the directory the script
  lives in).
- New `-db-dir`/`-database-directory` option (or `METABOLIC_DB_DIR` env var) points at an
  external database directory; defaults to `$METABOLIC_dir` for backward compatibility.
- All database paths (`METABOLIC_hmm_db`, `kofam_database`, `dbCAN2`, `MEROPS`,
  `METABOLIC_template_and_database`) now resolve via `$db_dir` instead of `$METABOLIC_dir`.
- New `_check_db_dir()` validates the expected layout up front and dies with a clear list of
  what's missing, instead of failing opaquely deep into a run.

## New `-download-db` self-setup mode

- New flag that downloads/builds the full database layout into `-db-dir` and exits without
  running an analysis. Idempotent — skips any database already present.
- New subs: `_download_databases`, `_setup_kofam_database`, `_setup_dbcan2_database`,
  `_setup_merops_database`, `_extract_archive_if_needed`, `_fetch`, `_run_cmd`,
  `_ensure_accessory_scripts`.
- Each remote source has a matching `-*-url`/`-*-source` override option, so sources can be
  re-pointed at internal mirrors or pre-staged files.

## Configurable test dataset location (`-test-files-dir`)

- `-test true` used to hardcode paths under `$METABOLIC_dir/METABOLIC_test_files`.
- Now configurable via `-test-files-dir` (still defaults there), since the upstream Figshare
  test bundle must be fetched manually via a browser.

## Bug fixes

- **Missing `-in`/`-in-gn` validation** (`METABOLIC-C.pl`, `METABOLIC-G.pl`): omitting both
  used to silently launch the full multi-thousand-job hmmsearch pipeline against an empty
  protein set instead of failing fast. Now dies immediately with a clear message.
- **Broken `-in` + `-r` genome coverage** (`METABOLIC-C.pl`): the documented workflow of
  passing `-in` (a protein folder) together with `-r` (reads) for coverage calculation was
  reading `.gene` files from `$input_genome_folder`, which is only ever set by `-in-gn` and
  is `undef` in `-in` mode — silently producing an empty depth file. Fixed to read from
  `$input_protein_folder`, which is populated in both `-in` and `-in-gn` modes (and is
  identical to `$input_genome_folder` whenever `-in-gn` is used, so `-in-gn` behavior is
  unchanged).

