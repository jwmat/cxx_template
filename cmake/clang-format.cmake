# =========================================================================================
# clang_format.cmake
#
# Adds custom targets:
#   - format        : formats all C++ source files using clang-format
#   - check-format  : checks formatting without modifying files (CI-friendly)
#
# Requires:
#   - .clang-format file at project root
#   - clang-format installed and in PATH
# =========================================================================================

# -----------------------------------------------------------------------------------------
# Locate clang-format binary
# -----------------------------------------------------------------------------------------
find_program(CLANG_FORMAT_EXE NAMES clang-format REQUIRED)

# -----------------------------------------------------------------------------------------
# Define source file globs (customize as needed)
# -----------------------------------------------------------------------------------------
file(GLOB_RECURSE CLANG_FORMAT_SOURCES
    "${CMAKE_SOURCE_DIR}/source/*.cpp"
    "${CMAKE_SOURCE_DIR}/include/*.h"
    "${CMAKE_SOURCE_DIR}/tests/*.cpp"
)

# -----------------------------------------------------------------------------------------
# format target: applies clang-format in-place
# -----------------------------------------------------------------------------------------
add_custom_target(format
    COMMAND ${CLANG_FORMAT_EXE}
            -i
            -style=file
            ${CLANG_FORMAT_SOURCES}
    COMMENT "Formatting source files with clang-format"
)

# -----------------------------------------------------------------------------------------
# check-format target: checks formatting without making changes (CI-friendly)
# -----------------------------------------------------------------------------------------
add_custom_target(check-format
    COMMAND ${CLANG_FORMAT_EXE}
            --dry-run
            --Werror
            -style=file
            ${CLANG_FORMAT_SOURCES}
    COMMENT "Checking code formatting (non-destructive)"
)
