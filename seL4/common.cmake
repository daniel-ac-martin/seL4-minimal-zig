# Avoid inline syscalls, as Zig can't handle them
# Note: This makes the binary much bigger
set(LibSel4FunctionAttributes public CACHE STRING "" FORCE)

# Debugging
set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "" FORCE)
set(KernelDebugBuild ON CACHE BOOL "" FORCE)
