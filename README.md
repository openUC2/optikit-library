# openUC2 OptiKit — the curated parts library

The parts openUC2 ships. Mount it in the configurator, or point a local
optikit-core service at it.

```
library/
  components/    optical prescriptions — frames, ports, surfaces (F2)
  templates/     mechanical housings/inserts — mesh, envelope, mounting (F3)
  modules/       one placeable cube: binds a component (or subdesign) + template
  subdesigns/    multi-part optics as a nested design (galvo pairs, stages)
  groups/        multi-cube arrangements placed as one rigid unit
  archive/       retired records, kept so a design that names one can be repaired
  setups/        designs saved from the running app ("save setup" in the editor)
  dist/index.json   `library build`'s local output — gitignored, not fetched
designs/     hand-authored reference instruments
setups/      curated complete builds, each with a preview image
library-index.json   the committed index — what mounting this repo fetches
             (CI regenerates it from library/ on every push to main)
```

## Relation to the Go DSN model

The wire format is Go's `.dsn` (`openUC2/optikit`, `optikit-design.yml`) — see
[DSN-CONTRACT.md](https://github.com/openUC2/optikit-v2/blob/main/DOCS/DSN-CONTRACT.md)
in optikit-core for the normative spec. Two kinds of thing live here:

- **`designs/`, `setups/`, and `library/setups/` are literal Go documents** —
  an `optikit-design.yml` with `components:`, `inputs:`, `paths:`, nothing
  library-specific. Open one in Go's own tooling; it needs nothing from us.
- **`library/{components,templates,modules,subdesigns,groups}/` are our
  catalog layer on top** — versioned, addressable records
  (`namespace.category.slug@version`) that a design's `components.<id>` can
  reference instead of inlining. Each `kind:` maps onto the model differently:
  - `optical_component` — the `optics:` block a placed `kind: primitive`
    component carries (ports, frames, surfaces). Pure prescription, no mesh.
  - `mechanical_template` — the mesh + the F2→F3 binding (`insert-pose`,
    `mesh-pose`, `footprint_grid`) that seats a component's optics inside a
    cube. Our extension; Go has no separate mounting record.
  - `cube_module` — the one thing the palette places. Resolves to a single
    Go component: `kind: primitive` (mesh + inlined `optics:`) for a
    component-backed module, or `kind: design` (a nested-design reference)
    for a subdesign-backed one.
  - `cube_subdesign` — a `cube_module`'s `design:` target when its optics
    can't be one record (e.g. a galvo's two independently-tilting mirrors).
    Its `optikit-design.yml` **is** an ordinary nested Go design; the
    `subdesign.yml` wrapper only adds the library id/version and,
    optionally, which `optical_component` it was decomposed from
    (`library decompose`, so the compact record's editors still resolve it).
  - `cube_group` — several modules placed together, sharing one transform.
    Go has no equivalent; it flattens to plain sibling components on export.

`library-index.json` is **not** DSN — it is our derived, read-only catalog:
components, templates and modules resolved into flat entries (ports folded
into the mounted frame, a subdesign's declared inputs and per-mirror
motions precomputed) so the configurator can populate the palette without
re-deriving any of it.

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
part, and deleting the note. Anything that still had an importer's `review:`
block at reset time is in `library/archive/` instead, and
`optikit-core library restore <id>` brings a trio back.

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
