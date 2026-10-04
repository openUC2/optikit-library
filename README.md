# openUC2 OptiKit — the curated parts library

The parts openUC2 ships. Mount it in the configurator, or point a local
optikit-core service at it.

```
library/
  components/    optical prescriptions — frames, surfaces (F2)
  templates/     mechanical housings/inserts — mesh, envelope, mounting (F3)
  designs/       Go designs, placed as `designs/<name>` — every module is one
                 (`module.yml` beside its `optikit-design.yml`: body mesh +
                 optic child, seats as variants, motion as inputs), plus
                 arrangements — the OPM: modules at grid cells, plates and
                 joints — and the design a moving housing binds
  setups/        designs saved from the running app ("save setup" in the editor)
  dist/index.json   `library build`'s local output — gitignored, not fetched
library-index.json   the committed index — what mounting this repo fetches
             (CI regenerates it from library/ on every push to main)
```

## Relation to the Go DSN model

The wire format is Go's `.dsn` (`openUC2/optikit`, `optikit-design.yml`) — see
[DSN-CONTRACT.md](https://github.com/openUC2/optikit-v2/blob/main/DOCS/DSN-CONTRACT.md)
in optikit-core for the normative spec. Two kinds of thing live here:

- **`library/setups/` holds literal Go documents** —
  an `optikit-design.yml` with `components:`, `inputs:`, `paths:`, nothing
  library-specific. Open one in Go's own tooling; it needs nothing from us.
- **`library/designs/` holds plain Go designs** — `designs/<name>/optikit-design.yml`,
  nothing around it; a setup reaches one through its `designs` symlink
  (Go's own `primitives -> ../../primitives/` convention). **Every module is
  one**: `designs/<module id>/` holds the design (a `body` child — the
  template mesh through the folder's `templates -> ../../templates` link,
  posed by `mesh-pose` — and the optic child with the component's optics
  seated by `insert-pose`; seats as `variants`, motion as `inputs`) and
  `module.yml`, the catalog record beside it (`template`, `component`,
  footprint, price, electronics, review). A placement anywhere is Go's own
  `kind: design` + `design: designs/<module id>`.
- **`library/{components,templates}/` are our catalog layer** — versioned,
  addressable records (`namespace.category.slug@version`):
  - `optical_component` — the `optics:` block a module's optic child (or a
    placed bare optic) carries (frames, surfaces). Pure prescription, no mesh.
  - `mechanical_template` — the mesh + the F2→F3 binding (`insert-pose`,
    `mesh-pose`, `footprint_grid`) that seats a component's optics inside a
    cube. Our extension; Go has no separate mounting record.
- The other designs under `designs/`: an **arrangement** — the OPM — whose
  components place modules at grid cells the way the schematic places them,
  plates and puzzle joints between the layers, the component tagged
  `interface/axis` the one a FRAME bay puts on its optical axis; and the
  design a moving housing binds (the FRAME stage: `dx/dy/dz` inputs move
  the `carriage` its `sample` mount rides, `mounts.sample.on: carriage`).

`library-index.json` is **not** DSN — it is our derived, read-only catalog:
components, templates and modules resolved into flat entries (record
frames as mounted, a subdesign's declared inputs and seats precomputed) so
the configurator can populate the palette without re-deriving any of it.

# Why? 

We wanted to outsource the library. This is now at https://github.com/openUC2/optikit-library

In order to link to the external folder, you have to do the following:

Assuming your library lives here ~/Downloads/OPTIKIT/optikit-core

```
cd ~/Downloads/OPTIKIT/optikit-core
uv run optikit-core library build --root ~/Downloads/OPTIKIT/optikit-library/library
cp ~/Downloads/OPTIKIT/optikit-library/library/{dist/index.json,../library-index.json}
```

Then in whatever script you use to start the server:

```py
import os
LIBRARY_ROOT_ENV = "OPTIKIT_LIBRARY_ROOT"

os.environ[LIBRARY_ROOT_ENV] = "/Users/bene/Downloads/OPTIKIT/optikit-library"  # --- REPLACE ---
```

The goal is to cleanup the existing parts/modules and start anew. So that we have real components inside the library. Since this will bloat up the repo, I have outsourced it. The `optikit-library` uses `git-lfs`. I had to install it, so beware of that. 



## Use it

**Mounted, read-only** — paste this repo's URL into the configurator's library
settings. Parts appear in the palette under this repo's badge.

**Locally, read-write** — point a service at it and author straight into it:

```bash
export OPTIKIT_LIBRARY_ROOT=/path/to/optikit-library/library
uv run optikit-core serve
```

Saving in the component editor writes here, and the part is in the palette on
the next request. Commit and push when you want to share it.

## What "unreviewed" means

Most records carry a `review:` note saying they were **carried over from the
pre-reset library and never confirmed against a real part**. That is not
decoration: the prescription may be an importer's guess.

The configurator badges them everywhere they appear. Clearing the badge means
opening the record in the component editor, checking it against the physical
part, and deleting the note. Legacy and placeholder records were removed on
2026-09-17 (`scripts/remove_legacy.sh`); real parts come back through the
wizards and the insert designer, never from an archive.

The 18 `starter` records are exempt and always were — they are the exemplars
people copy, so a flag on them would mean the thing being copied is itself
unconfirmed.

## Contributing

Fork, add records under `library/`, open a PR. CI validates every push and
rebuilds the index. Use `user.*` ids for anything experimental — namespacing is
what stops a contribution shadowing a curated part.

## Meshes are git-LFS

`.gitattributes` sends `*.glb`, `*.step`, `*.stp`, `*.stl`, `*.3mf` to LFS.
**Install it before adding any mesh** — a mesh committed as an ordinary blob
can only be converted by rewriting history:

```bash
git lfs install
```
