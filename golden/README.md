# golden/ — the record twin of optikit-core's `golden/` designs

The curated trios (`locked: true`) plus the records the optikit-core test
suite reads, moved out of `library/` on 2026-09-21 (WP-322f). Tests run
against this root (`OPTIKIT_LIBRARY_ROOT=…/optikit-library/golden`, the
default `tests/conftest.py` sets; CI does the same). The service never
serves it: `library/` is the users' root, and it holds only view links to
the structural carriers kept here (frame, plates, puzzle).

Do not author here. A record that a test needs gets added by the PR that
adds the test; everything else belongs in `library/` or `archive/`.
