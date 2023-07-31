#!/usr/bin/env -S cmake -P

# Build kernel.elf
include(${CMAKE_CURRENT_LIST_DIR}/../deps/seL4/seL4/tools/helpers.cmake)
cmake_script_build_kernel()

set(KernelPlatform "pc99" CACHE STRING "")
set(KernelSel4Arch "x86_64" CACHE STRING "")
#set(KernelVerificationBuild ON CACHE BOOL "")
set(KernelVerificationBuild OFF CACHE BOOL "")
set(KernelMaxNumNodes "1" CACHE STRING "")
set(KernelOptimisation "-O2" CACHE STRING "")
set(KernelRetypeFanOutLimit "256" CACHE STRING "")
set(KernelBenchmarks "none" CACHE STRING "")
set(KernelDangerousCodeInjection OFF CACHE BOOL "")
set(KernelFastpath ON CACHE BOOL "")
#set(KernelPrinting OFF CACHE BOOL "")
set(KernelPrinting ON CACHE BOOL "") # For debug
set(KernelNumDomains 16 CACHE STRING "")
#set(KernelNumDomains 1 CACHE STRING "") # To copy tutorial (no known benefit)
set(KernelRootCNodeSizeBits 19 CACHE STRING "")
#set(KernelRootCNodeSizeBits 16 CACHE STRING "") # To copy tutorial (no known benefit)
#set(KernelMaxNumBootinfoUntypedCaps 50 CACHE STRING "")
set(KernelMaxNumBootinfoUntypedCaps 230 CACHE STRING "") # To copy tutorial (Avoids: Kernel init: Too many untyped regions for boot info)
#set(KernelFSGSBase "inst" CACHE STRING "")

#set(KernelIsMCS OFF CACHE BOOL "")
set(KernelIsMCS ON CACHE BOOL "")

# Simulation support
set(KernelSupportPCID OFF CACHE BOOL "" FORCE)
set(KernelFSGSBase msr CACHE STRING "" FORCE)
set(KernelIOMMU OFF CACHE BOOL "" FORCE)
set(KernelFPU FXSAVE CACHE STRING "" FORCE)

# Debugging
set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "" FORCE)
set(KernelDebugBuild ON CACHE BOOL "" FORCE)
