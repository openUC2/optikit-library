#!/usr/bin/env bash
# Remove the legacy and placeholder records from the library (2026-09-17).
#
# Legacy: archive/ (port-era tombstones), the root designs/ and setups/ (port-era
# Go documents; library/setups/ supersedes them), and the WP-43 CSV-migrated
# openuc2 palette whose template mesh never shipped (a `glb-url` into the old
# Store repo, no file on disk). Placeholders: records that say so themselves —
# tag `placeholder`, or a review line "CAD/specs/mesh pending". Groups, modules
# and subdesigns that only arrange those go with them. Everything else stays:
# the user.* Inventor exports, the Thorlabs/objective prescriptions, the
# openuc2 mirror_1x1 trio (real TH1 V03 mesh), the electronics_v3 component
# (the one authored symbol), the mesh-less starter housings
# the wizards seat, and openuc2.subdesign.mounted_mirror (Go parity corpus;
# its module now sits on the real cube shell, user.tpl.cube_base).
#
# Run from the repo root. Deletions only; nothing here is rewritten.
set -euo pipefail
cd "$(dirname "$0")/.."

git rm -rqf library/archive designs setups
rmdir library/templates/user.tpl.automatic_xyz_stage \
      library/templates/user.tpl.my_next_motorized_xyzstage \
      library/templates/user.tpl.my_xyz_stage 2>/dev/null || true

# WP-43 palette: template mesh not on disk
for n in cube_1x1 electronics_v3 galvo_xy laser_488nm pinhole_1x1 \
         sampleholder_1x1 tube_lens_1x1 xy_stage camera_usb filter_dichroic; do
  for d in library/templates/openuc2.tpl.$n library/modules/openuc2.cube.$n; do
    [ -d "$d" ] && git rm -rqf "$d"
  done
done
for c in openuc2.mechanics.cube_1x1 openuc2.mirror.galvo_xy openuc2.source.laser_488nm \
         openuc2.mechanics.pinhole_1x1 openuc2.sample.sampleholder_1x1 \
         openuc2.lens.tube_lens_1x1 openuc2.mechanics.xy_stage \
         openuc2.detector.camera_usb; do
  [ -d "library/components/$c" ] && git rm -rqf "library/components/$c"
done

# placeholders
for t in mirror_mount_1x1 camera_mount_1x1 laser_pointer_1x1 fiber_coupler_1x1 \
         laser_850nm_ir galvo_sub baseplate_4x4 baseplate_8x4; do
  git rm -rqf "library/templates/openuc2.tpl.$t"
done
for m in mirror_45 camera_cs165 laser_488 laser_fiber_405 laser_fiber_488 \
         laser_fiber_488_635 laser_fiber_532 laser_fiber_635 laser_fiber_quad \
         laser_850nm_ir galvo_sub baseplate_4x4 baseplate_8x4; do
  git rm -rqf "library/modules/openuc2.cube.$m"
done
for c in openuc2.source.laser_fiber_405 openuc2.source.laser_fiber_488 \
         openuc2.source.laser_fiber_488_635 openuc2.source.laser_fiber_532 \
         openuc2.source.laser_fiber_635 openuc2.source.laser_fiber_quad \
         openuc2.mechanics.baseplate_4x4 openuc2.mechanics.baseplate_8x4; do
  git rm -rqf "library/components/$c"
done
for s in laser_fiber_405 laser_fiber_488 laser_fiber_488_635 laser_fiber_532 \
         laser_fiber_635 laser_fiber_quad laser_850nm_ir mounted_galvo \
         laser_488 camera_cs165; do
  git rm -rqf "library/subdesigns/openuc2.subdesign.$s"
done

# groups arranged from the removed modules
git rm -rqf library/groups

echo "removed $(git status --short | grep -c '^D') files; now: optikit-core library build"
