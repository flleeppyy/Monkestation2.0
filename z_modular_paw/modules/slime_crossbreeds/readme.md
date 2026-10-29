https://github.com/Monkestation/Monkes-Paw/pull/7

## Slime Crossbreeds

Module ID: SLIME_CROSSBREEDS

### Description:

the crossbreeds Paw has that Monkestation's slime rancher doesn't. the rest of slime rancher lives upstream now, this is just what's left over:

- gentle extracts: activate an extract's minor or major effect without eating it
- crystalline extracts: place a slimic pylon that does stuff to whoever's near it
- warping extracts: draw runes on the floor. the black rune makes weapons starborne, the rainbow rune opens a pocket room
- transformative extracts: permanently change a slime *and* its babies. max three per slime

### TG Proc/File Changes:

- `code/modules/mob/living/basic/slime/actions.dm`: `finish_reproduce()` sends `COMSIG_SLIME_SPLIT` for the new baby, and leaves a cerulean-transformed parent an adult
- `code/modules/mob/living/basic/slime/life.dm`: `handle_nutrition()` skips the hunger drain on silver-transformed slimes
- `code/datums/components/orbiter.dm`: ending an orbit actually stops the spin animation, so a starborne weapon quits circling once it's picked up (upstream bug, nobody noticed bc ghosts restart their float animation right after)

### Modular Overrides:

- N/A

### Defines:

- `code/__DEFINES/~paw_defines/slime_crossbreeds.dm`: `COMSIG_SLIME_SPLIT`

### Included files that are not contained in this module:

- `_maps/templates/paw/warped_room.dmm` - the pocket room behind the rainbow warping rune, bc map templates have to live under `_maps/`

### Credits:

- Absolucy - the original slime rancher rework ([OculisStation PR #472](https://github.com/OculisStation/OculisStation/pull/472)) and this port
- BeeStation and OculisStation - the warping crossbreeds and the warped room map
