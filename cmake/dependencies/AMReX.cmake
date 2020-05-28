macro(find_amrex)
    if(HiPACE_amrex_internal)
        include(FetchContent)
        set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)

        # see https://amrex-codes.github.io/amrex/docs_html/BuildingAMReX.html#customization-options
        set(ENABLE_FORTRAN OFF CACHE INTERNAL "")
        set(ENABLE_FORTRAN_INTERFACES OFF CACHE INTERNAL "")
        set(ENABLE_TUTORIALS OFF CACHE INTERNAL "")
        set(ENABLE_PARTICLES ON CACHE INTERNAL "")
        set(ENABLE_TINY_PROFILE ON CACHE INTERNAL "")
        set(ENABLE_LINEAR_SOLVERS OFF CACHE INTERNAL "")
        set(AMReX_DIM 3 CACHE INTERNAL "")
        # we'll need this for Python bindings
        #set(ENABLE_PIC ON CACHE INTERNAL "")

        FetchContent_Declare(fetchedamrex
                GIT_REPOSITORY ${HiPACE_amrex_repo}
                GIT_TAG        ${HiPACE_amrex_branch}
                BUILD_IN_SOURCE 0
        )
        FetchContent_GetProperties(fetchedamrex)

        if(NOT fetchedamrex_POPULATED)
            FetchContent_Populate(fetchedamrex)
            list(APPEND CMAKE_MODULE_PATH "${fetchedamrex_SOURCE_DIR}/Tools/CMake")
            if(ENABLE_CUDA)
                enable_language(CUDA)
                include(AMReX_SetupCUDA)
            endif()
            add_subdirectory(${fetchedamrex_SOURCE_DIR} ${fetchedamrex_BINARY_DIR})
        endif()

        # advanced fetch options
        mark_as_advanced(FETCHCONTENT_BASE_DIR)
        mark_as_advanced(FETCHCONTENT_FULLY_DISCONNECTED)
        mark_as_advanced(FETCHCONTENT_QUIET)
        mark_as_advanced(FETCHCONTENT_SOURCE_DIR_FETCHEDAMREX)
        mark_as_advanced(FETCHCONTENT_UPDATES_DISCONNECTED)
        mark_as_advanced(FETCHCONTENT_UPDATES_DISCONNECTED_FETCHEDAMREX)

        # AMReX options not relevant to HiPACE users
        mark_as_advanced(DIM)
        mark_as_advanced(USE_XSDK_DEFAULTS)

        message(STATUS "AMReX: Using INTERNAL version '${AMREX_PKG_VERSION}' (${AMREX_GIT_VERSION})")
    else()
        find_package(AMReX 20.05 CONFIG REQUIRED COMPONENTS 3D PARTICLES DPARTICLES DP TINYP)
        message(STATUS "AMReX: Found version '${AMReX_VERSION}'")
    endif()
endmacro()

set(HiPACE_amrex_repo "https://github.com/AMReX-Codes/amrex.git"
    CACHE STRING
    "Repository URI to pull and build AMReX from if(HiPACE_amrex_internal)")
set(HiPACE_amrex_branch "development"
    CACHE STRING
    "Repository branch for HiPACE_amrex_repo if(HiPACE_amrex_internal)")

find_amrex()
