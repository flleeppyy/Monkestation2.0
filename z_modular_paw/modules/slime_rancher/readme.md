https://github.com/Monkestation/Monkes-Paw/pull/7

## Slime Rancher

Module ID: SLIME_RANCHER

### Description:

rips out slimecore xenobio and replaces it with the slime rancher loop i wrote for OculisStation.

the short version:

- slimes live in pens. a pen is just four corner posts
- adult slimes turn the health they drain into extracts. feed them certain items (or let them drain certain critters) and they mutate instead
- the vacuum pack sucks up slimes to move them around, and turns critters into biomass. the biomass recycler turns that into monkey cubes and breeding pellets
- transformative extracts (made in the extract compressor) permanently change a slime *and* its babies. cat slimes, cleaner slimes, that kinda thing. max three per slime. cat slimes also hop over and harmlessly bounce off of people now and then

the slime mob itself is just tg's basic slime, but with the AI rewritten in `code/slime_ai.dm`.

slimecore isn't deleted btw, it's still on disk, just unticked. that way upstream merges still apply cleanly instead of exploding. `code/legacy_slimecore.dm` converts the old slimecore map objects so existing maps don't break.

### TG Proc/File Changes:

- `tgstation.dme`: unticked most of slimecore. no PAW EDIT markers here, bc Dream Maker rewrites the include block and would eat them anyways
- the unticked slimecore files under `monkestation/code/modules/slimecore/` each have a marker on line 1
- `code/modules/unit_tests/linked_xenobio_pens.dm`: commented out (it tests slimecore's pen consoles, which are gone), and excluded in `tools/ticked_file_enforcement/schemas/unit_tests.json`
- swapped slimecore API calls for the basic slime ones in:
	- `code/modules/reagents/chemistry/recipes/slime_extracts.dm`
	- `code/modules/research/xenobiology/xenobiology.dm`
	- `code/modules/research/xenobiology/crossbreeding/` (`burning.dm`, `charged.dm`, `chilling.dm`, `regenerative.dm`, `_status_effects.dm`)
	- `code/modules/antagonists/abductor/equipment/glands/slime.dm`
	- `code/game/objects/effects/anomalies/anomalies_pyroclastic.dm`
	- `code/modules/mob_spawn/corpses/nonhuman_corpses.dm`
- yeeted slimecore items from:
	- `code/game/objects/items/stacks/sheets/sheet_types.dm`
	- `code/game/objects/items/robot/items/storage.dm`
	- `monkestation/code/modules/cargo/crates/science.dm` (this one also gets the new compressor board and vacuum pack)
- `code/__HELPERS/paths/path.dm`: pen barriers count as directional blockers on the tile a path leaves from, so mobs don't try to path straight through a fence
- `code/datums/components/orbiter.dm`: ending an orbit actually stops the spin animation, so a starborne weapon quits circling once it's picked up (upstream bug, nobody noticed bc ghosts restart their float animation right after)
- `tgui/packages/tgui/styles/main.scss`: loads the slime rancher stylesheets

### Modular Overrides:

all under `z_modular_paw/master_files/code/`:

- `__HELPERS/paths/path.dm`
- `datums/ai/monkey/monkey_behaviors.dm`
- `datums/ai/monkey/monkey_controller.dm`
- `game/objects/items/storage/bags.dm`
- `modules/food_and_drinks/machinery/smartfridge.dm`
- `modules/mob/living/basic/basic.dm`
- `modules/research/techweb/service_nodes.dm`
- `modules/research/xenobiology/crossbreeding/__corecross.dm`

### Defines:

- `code/__DEFINES/~paw_defines/slime_rancher.dm`

### Included files that are not contained in this module:

tgui stuff, bc tgui can't be modular. all under `tgui/packages/tgui/`:

- `interfaces/SlimePen.tsx`
- `interfaces/SlimeRancherScanner.tsx`
- `interfaces/common/SlimeRancher.tsx`
- `styles/interfaces/SlimePen.scss`
- `styles/interfaces/SlimeRancherScanner.scss`
- `styles/themes/slime_rancher.scss`

and one map, bc map templates have to live under `_maps/`:

- `_maps/templates/paw/warped_room.dmm` - the pocket room behind the rainbow warping rune

### Credits:

- Absolucy - the original rework ([OculisStation PR #472](https://github.com/OculisStation/OculisStation/pull/472)) and this port
- tgstation - the basic slime mob
- BeeStation and OculisStation - the warping crossbreeds and the warped room map
- sprites: see `icons/attributions.txt`
