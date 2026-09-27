<!-- This should be copy-pasted into the root of your module folder as readme.md -->

https://github.com/Monkestation/Monkes-Paw/pull/3

## Cross DB

Module ID: MONKE_CROSS_DB

### Description:

cross db support to read patreon key stuff and other things that should be cross.
Library, achievements, patreon data,

### TG Proc/File Changes:

- N/A
<!-- If you edited any core procs, you should list them here. You should specify the files and procs you changed.
E.g:
- `code/modules/mob/living.dm`: `proc/overriden_proc`, `var/overriden_var`
  -->
- `code/controllers/subsystem/achievements.dm`: `proc/update_metadata`
- `code/controllers/subsystem/dbcore.dm`: `proc/NewQuery`, `proc/MassInsert`
- `code/datums/patreon_data.dm`: `proc/fetch_key_and_rank`, `proc/get_patreon_rank`
- `code/datums/achievements/_achievement_data.dm`: `proc/load_all_achievements`,
- `code/datums/achievements/_awards.dm`: `proc/get_raw_value`, `proc/LoadHighScores`, `/datum/award/score/achievements_score/get_ui_data`, `/datum/award/score/achievements_score/on_achievement_data_init`
- `code/modules/library/admin_only.dm`: `/update_page_contents`, `/update_page_count`, `/view_book`, `get_book_history`, `hide_book` ok im not copying and pasting every single proc name fuck you use your god damn eyes
- `code/modules/library/lib_machines.dm`
- `code/modules/library/random_books.dm`

### Modular Overrides:

- N/A / Look in the dbcore.db file in this module
<!-- If you added a new modular override (file or code-wise) for your module, you should list it here. Code files should specify what procs they changed, in case of multiple modules using the same file.
E.g:
- `z_modular_paw/master_files/sound/my_cool_sound.ogg`
- `z_modular_paw/master_files/code/my_modular_override.dm`: `proc/overriden_proc`, `var/overriden_var`
  -->

### Defines:

- N/A
<!-- If you needed to add any defines, mention the files you added those defines in, along with the name of the defines. -->

### Included files that are not contained in this module:

- `code/controllers/configuration/entries/~paw.dm`
<!-- Likewise, be it a non-modular file or a modular one that's not contained within the folder belonging to this specific module, it should be mentioned here. Good examples are icons or sounds that are used between multiple modules, or other such edge-cases. -->

### Credits:

Flleeppyy
Borbop (original cross code)

<!-- Here go the credits to you, dear coder, and in case of collaborative work or ports, credits to the original source of the code. -->
