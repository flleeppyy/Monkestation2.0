https://github.com/Monkestation/Monkes-Paw/pull/12

## Simple map votes

Module ID: SIMPLE_MAP_VOTE

### Description:

Makes it so map votes just choose whichever map had the most votes, instead of the tally bullshit.

also there's a fancy tiebreaker doohickey - recent maps lose to less recent maps.

### TG Proc/File Changes:

- N/A

### Modular Overrides:

- `z_modular_paw/master_files/code/datums/votes/map_vote.dm`: `proc/finalize_vote`, `proc/tiebreaker`
- `z_modular_paw/master_files/code/controllers/subsystem/map_vote.dm`: `proc/update_tally_printout`

### Defines:

- N/A

### Included files that are not contained in this module:

- N/A

### Credits:

Lucy
