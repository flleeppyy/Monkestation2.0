<!-- This should be copy-pasted into the root of your module folder as readme.md -->

https://github.com/Monkestation/Monkes-Paw/pull/26

## \<Title Here> Craftable Tiny Fans

Module ID: TINY_FANS

### Description:

- adds a simple crafting recipe for tiny fans
- adds a deconstruction hint for deconstructing tiny fans
- recipes are unequal, deconstruction does not return materials used in crafting
<!-- Here, try to describe what your PR does, what features it provides and any other directly useful information. -->

### TG Proc/File Changes:

- N/A
<!-- If you edited any core procs, you should list them here. You should specify the files and procs you changed.
E.g:
- `code/modules/mob/living.dm`: `proc/overriden_proc`, `var/overriden_var`
  -->

### Modular Overrides:

- `z_modular_paw/modules/tiny_fan/fans.dm`: `/obj/structure/fans/examine`
<!-- If you added a new modular override (file or code-wise) for your module, you should list it here. Code files should specify what procs they changed, in case of multiple modules using the same file.
E.g:
- `z_modular_paw/master_files/sound/my_cool_sound.ogg`
- `z_modular_paw/master_files/code/my_modular_override.dm`: `proc/overriden_proc`, `var/overriden_var`
  -->

### Defines:

- `z_modular_paw/modules/tiny_fan/crafting.dm`: `/datum/crafting_recipe/tiny_fan`
<!-- If you needed to add any defines, mention the files you added those defines in, along with the name of the defines. -->

### Included files that are not contained in this module:

- N/A
<!-- Likewise, be it a non-modular file or a modular one that's not contained within the folder belonging to this specific module, it should be mentioned here. Good examples are icons or sounds that are used between multiple modules, or other such edge-cases. -->

### Credits:

- Thanks Lettuce_Guardian for suggestions
<!-- Here go the credits to you, dear coder, and in case of collaborative work or ports, credits to the original source of the code. -->
