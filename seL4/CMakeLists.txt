cmake_minimum_required(VERSION 3.7.2)
project(seL4-deps C ASM)

set(project_dir "${CMAKE_CURRENT_LIST_DIR}/..")
set(deps_dir "${project_dir}/deps")

list(
  APPEND
    CMAKE_MODULE_PATH
    ${deps_dir}/seL4/musllibc
    ${deps_dir}/seL4/seL4
    ${deps_dir}/seL4/seL4_tools/cmake-tool/helpers
)

include(application_settings)

include(${deps_dir}/seL4/seL4/configs/seL4Config.cmake)

# We must build the debug kernel because the tutorials rely on seL4_DebugPutChar
# and they don't initialize a platsupport driver.
ApplyCommonReleaseVerificationSettings(FALSE FALSE)

# We will attempt to generate a simulation script, so try and generate a simulation
# compatible configuration
ApplyCommonSimulationSettings(${KernelSel4Arch})
if(FORCE_IOMMU)
    set(KernelIOMMU ON CACHE BOOL "" FORCE)
endif()

find_package(seL4 REQUIRED)
find_package(musllibc REQUIRED)

sel4_import_kernel()
sel4_import_libsel4()
musllibc_import_library()

add_subdirectory(include include)

include(simulation)
GenerateSimulateScript()
