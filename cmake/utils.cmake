# -----------------------------------------------------------------------------------------
# Function: get_targets_in_directory(<dir> <out_var>)
# Recursively collects all build system targets defined in the given directory and its
# subdirectories. Outputs the result to the named variable.
# -----------------------------------------------------------------------------------------
function(get_targets_in_directory directory out_var)
    get_directory_property(subdirs DIRECTORY ${directory} SUBDIRECTORIES)

    foreach(subdir IN LISTS subdirs)
        get_targets_in_directory(${subdir} subtargets)
        list(APPEND targets ${subtargets})
    endforeach()

    get_directory_property(local_targets DIRECTORY ${directory} BUILD_SYSTEM_TARGETS)
    list(APPEND targets ${local_targets})

    set(${out_var} ${targets} PARENT_SCOPE)
endfunction()
