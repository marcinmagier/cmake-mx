
# CPU options
if(NOT CPU_TYPE)
    get_property(CPU_TYPE GLOBAL PROPERTY "CPU_TYPE")
endif()
if(NOT CPU_ARCH)
    get_property(CPU_ARCH GLOBAL PROPERTY "CPU_ARCH")
endif()
if(NOT CPU_TYPE AND NOT CPU_ARCH)
    message( WARNING "Specify CPU type or architecture - argument for -mcpu / -march")
    message( "CPU_TYPE: cortex-m0, cortex-m1, cortex-m3, cortex-m4")
    message( "CPU_ARCH: armv6-m, armv7-m, armv7e-m, armv7-r, armv7-a")
endif()

if(NOT CPU_FAMILY)
    get_property(CPU_FAMILY GLOBAL PROPERTY "CPU_FAMILY")
    if(NOT CPU_FAMILY)
        message( WARNING "Specify CPU family - rough cpu symbol")
    endif()
endif()

if(NOT CPU_MODEL)
    get_property(CPU_MODEL GLOBAL PROPERTY "CPU_MODEL")
    if(NOT CPU_MODEL)
        message( WARNING "Specify CPU model - exact cpu token")
    endif()
endif()


# Linker script
if(NOT LINKER_SCRIPT)
    get_property(LINKER_SCRIPT GLOBAL PROPERTY "LINKER_SCRIPT")
    if(NOT LINKER_SCRIPT)
        message( FATAL_ERROR "Linker script not specified")
    endif()
endif()



# Asm flags
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -x assembler-with-cpp")



# C flags
set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -fverbose-asm")
set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -mthumb")
if(CPU_TYPE)
    set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -mcpu=${CPU_TYPE}")
endif()
if(CPU_ARCH)
    set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -march=${CPU_ARCH}")
endif()
if(CPU_FP_TYPE EQUAL soft)
    set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -mfloat-abi=softfp -mfpu=fpv4-sp-d16")
elseif(CPU_FP_TYPE EQUAL hard)
    set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -mfloat-abi=hard -mfpu=fpv4-sp-d16")
endif()



# C++ flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-rtti")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fverbose-asm")



# Link flags
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -T${LINKER_SCRIPT}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-Map=${PRJ_APP_NAME}.map,--cref,--no-warn-mismatch")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --specs=nano.specs")



# clear -shared -rdynamic
set(CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS "")
set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS   "")

