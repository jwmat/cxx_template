# =========================================================================================
# gtest.cmake
#
# Provides GoogleTest integration using either:
#   - System-installed GTest via find_package(GTest CONFIG), or
#   - FetchContent fallback (if not found)
#
# Also defines a helper function:
#   add_test_executable(<target> <sources>)
#     - Builds a test executable
#     - Registers it with CTest
#     - Links it with GTest
#     - Applies macOS RPATH fix
# =========================================================================================

# Attempt to use a system-provided GTest first
find_package(GTest CONFIG)

if(NOT GTest_FOUND)
  # Only set options if GTest wasn't found
  option(BUILD_GMOCK "Builds the googlemock subproject" OFF)
  option(INSTALL_GTEST "Enable installation of googletest" OFF)

  # Ensure shared CRT is used (mostly for MSVC)
  set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

  include(FetchContent)

  FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG        6910c9d9165801d8827d628cb72eb7ea9dd538c5 # v1.16.0
  )

  FetchContent_MakeAvailable(googletest)
endif()

# -----------------------------------------------------------------------------------------
# Function: add_test_executable(target sources)
# Adds a test executable, links it to GTest, and registers it with CTest
# -----------------------------------------------------------------------------------------
function(add_test_executable target sources)
  add_executable(${target} ${sources})
  add_test(NAME ${target} COMMAND $<TARGET_FILE:${target}>)

  target_link_libraries(${target}
    PRIVATE GTest::gtest GTest::gtest_main
  )

  # On macOS, fix RPATH for @rpath-linked gtest_main.dylib
  if(APPLE)
    set_target_properties(${target} PROPERTIES
      BUILD_WITH_INSTALL_RPATH TRUE
      INSTALL_RPATH "$<TARGET_FILE_DIR:GTest::gtest_main>"
    )
  endif()
endfunction()
