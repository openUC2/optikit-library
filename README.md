# openUC2 OptiKit — the curated parts library

The parts openUC2 ships. Mount it in the configurator, or point a local
optikit-core service at it.

```
library/     the parts — component / template / module trios, plus groups
  archive/   retired records, kept so a design that names one can be repaired
designs/     reference instruments
setups/      complete builds: a design + the records it needs + docs
library-index.json   what the configurator fetches (CI rebuilds it)
```

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
