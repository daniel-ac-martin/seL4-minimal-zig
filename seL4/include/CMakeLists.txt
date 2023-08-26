cmake_minimum_required(VERSION 3.7.2)
project(include C)

set(header_name "sel4/sel4.h")
set(include_gen "${CMAKE_CURRENT_BINARY_DIR}")
set(header_gen "${include_gen}/${header_name}")
set(roottask_dep "${CMAKE_CURRENT_SOURCE_DIR}/src/main.c")
# set(lib_dep "${CMAKE_CURRENT_SOURCE_DIR}/src/lib.c")
set(dep "${CMAKE_CURRENT_SOURCE_DIR}/include/sel4/sel4.h")

# Dummy root-task
add_executable(roottask ${roottask_dep})
target_link_libraries(
  roottask
  PUBLIC
  PRIVATE
    sel4
    muslc
    sel4_autoconf
)
include(rootserver)
DeclareRootserver(roottask)

# libsel4
# add_library(sel4_static STATIC ${lib_dep})
# target_link_libraries(
#   sel4_static
#   PUBLIC
#     sel4
#     muslc
#   PRIVATE
#     sel4_autoconf
# )

add_custom_command(
  OUTPUT
    "${header_gen}"
  COMMAND
    rm -f "${header_gen}"
  COMMAND
    cpp "$<LIST:TRANSFORM,$<TARGET_PROPERTY:roottask,INCLUDE_DIRECTORIES>,PREPEND,-I>" "${dep}" > "${header_gen}"
  COMMAND
    sed -i -E "s/\\)\\s+\\{/)\\n{/" "${header_gen}"
  COMMAND
    sed -i -E "s/^\\{\$/\;\\n{/" "${header_gen}"
  COMMAND
    sed -i -E "/^\\{\$/,/^\\}\$/d" "${header_gen}"
  COMMAND_EXPAND_LISTS
  DEPENDS
    "${dep}"
  COMMENT
    "Generate ${header_gen}"
  VERBATIM
)

add_custom_target(include
  ALL
  DEPENDS
    "${header_gen}"
  COMMENT
    "Include directory"
  VERBATIM
)
add_dependencies(include sel4 sel4_generated)
