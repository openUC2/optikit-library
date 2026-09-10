# Objective barrels and camera bodies (source CAD)

STEP exports from the openUC2 Inventor workspace
(`workspace/BUY/02 - Cameras and objectives`), AP214, millimetres, exported as
the parts sit. They are the `--step` input to
`optikit-core import objective` — see
`optikit-core/DOCS/editor/objectives-from-catalog.md` for the road and the
appendix that re-runs the whole table.

- A file named for a record slug (`soptop_hr_20x.stp`) is the barrel that
  record ships. The others are named for the CAD part and are waiting on a
  decision about which record they belong to.
- The parts are drawn with the **optical axis along +y**, the mounting
  shoulder at the origin, the thread protruding to −y — so the import line
  needs `--step-axis +y`. The mesh is never rotated; the housing template
  says the turn as a `mesh-pose` grid rotation.
- Matched on each part's own iProperty part number, not its file name: the
  file called `Nikon CFI Lambda PLAN APO 4X` is a `SemiAPO 4X/0,10` inside.

`camera_usb.stp` is the HIK MV-CS060 body. The MV-CE060 variants are the same
solid, so they are not kept here; MV-CA023 and the Tucsen Libra16 have no CAD
in the workspace at all.
