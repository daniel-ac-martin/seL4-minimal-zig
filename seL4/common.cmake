# Build kernel.elf
include(${CMAKE_CURRENT_LIST_DIR}/../deps/seL4/seL4/tools/helpers.cmake)
cmake_script_build_kernel()

# Avoid inline syscalls, as Zig can't handle them
# Note: This makes the binary much bigger
set(LibSel4FunctionAttributes public CACHE STRING "" FORCE)

# Debugging
set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "" FORCE)
set(KernelDebugBuild ON CACHE BOOL "" FORCE)
