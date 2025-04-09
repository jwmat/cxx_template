# =========================================================================================
# llvm-coverage.cmake
#
# Enables Clang-based code coverage instrumentation and generates a unified HTML report.
#
# Usage:
#   1. Call enable_code_coverage(<target>) for each test binary
#   2. Call add_global_coverage_target() once at the end
#
# Requirements:
#   - Clang compiler
#   - llvm-profdata and llvm-cov (must match the compiler version)
# =========================================================================================

# Keep a global list of coverage-enabled targets
set(COVERAGE_TARGETS "" CACHE INTERNAL "Targets with coverage enabled")

# -----------------------------------------------------------------------------------------
# Function: enable_code_coverage(target)
# Adds coverage instrumentation flags to the given target and registers it for reporting
# -----------------------------------------------------------------------------------------
function(enable_code_coverage target_name)
  if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    message(WARNING "Code coverage is only supported with Clang")
    return()
  endif()

  find_program(LLVM_COV_EXECUTABLE llvm-cov REQUIRED)
  find_program(LLVM_PROFDATA_EXECUTABLE llvm-profdata REQUIRED)

  set(COVERAGE_FLAGS
    --coverage
    -fprofile-instr-generate
    -fcoverage-mapping
  )

  target_compile_options(${target_name} PRIVATE ${COVERAGE_FLAGS})
  target_link_options(${target_name} PRIVATE ${COVERAGE_FLAGS})

  list(APPEND COVERAGE_TARGETS ${target_name})
  set(COVERAGE_TARGETS "${COVERAGE_TARGETS}" CACHE INTERNAL "Targets with coverage enabled")
endfunction()

# -----------------------------------------------------------------------------------------
# Function: add_global_coverage_target()
# Creates a `coverage` target that:
#   - Runs all registered coverage-enabled test targets
#   - Merges their raw profile output into a single .profdata file
#   - Generates an HTML report using llvm-cov
# -----------------------------------------------------------------------------------------
function(add_global_coverage_target)
  if(NOT COVERAGE_TARGETS)
    message(WARNING "No targets registered for coverage")
    return()
  endif()

  find_program(LLVM_COV_EXECUTABLE llvm-cov REQUIRED)
  find_program(LLVM_PROFDATA_EXECUTABLE llvm-profdata REQUIRED)

  set(REPORT_DIR "${CMAKE_BINARY_DIR}/coverage")
  set(PROFDATA_FILE "${REPORT_DIR}/merged.profdata")

  set(RUN_COMMANDS "")
  set(PROFRAW_FILES "")
  set(TARGET_FILES "")

  foreach(target IN LISTS COVERAGE_TARGETS)
    list(APPEND RUN_COMMANDS
      COMMAND ${CMAKE_COMMAND} -E env
              LLVM_PROFILE_FILE=${REPORT_DIR}/${target}.profraw
              $<TARGET_FILE:${target}>
    )
    list(APPEND PROFRAW_FILES "${REPORT_DIR}/${target}.profraw")
    list(APPEND TARGET_FILES "$<TARGET_FILE:${target}>")
  endforeach()

  add_custom_target(coverage
    ${RUN_COMMANDS}
    COMMAND ${LLVM_PROFDATA_EXECUTABLE} merge -sparse ${PROFRAW_FILES} -o ${PROFDATA_FILE}
    COMMAND ${LLVM_COV_EXECUTABLE} show ${TARGET_FILES}
            -instr-profile=${PROFDATA_FILE}
            -format=html -output-dir=${REPORT_DIR}
            -ignore-filename-regex="/usr|external"
    COMMENT "Generating unified coverage report in ${REPORT_DIR}/"
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    DEPENDS ${COVERAGE_TARGETS}
  )
endfunction()
