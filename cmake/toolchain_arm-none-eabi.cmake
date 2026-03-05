
########################################################################
# Set up cross compiler tools
########################################################################


set(TARGET_ARCH             arm)
set(TARGET_TOOLCHAIN        arm-none-eabi)

# check toolchain directory
if(NOT TARGET_TOOLCHAIN_DIR)
    set(TARGET_TOOLCHAIN_DIR $ENV{TARGET_TOOLCHAIN_DIR})
endif()
if(NOT TARGET_TOOLCHAIN_DIR)
    if(WIN32)
        set(TARGET_TOOLCHAIN_DIR    C:/toolchain/${TARGET_TOOLCHAIN})
    else()
        set(TARGET_TOOLCHAIN_DIR    /opt/toolchain/${TARGET_TOOLCHAIN})
    endif()
endif()
if(NOT EXISTS ${TARGET_TOOLCHAIN_DIR})
    message("Toolchain directory not found.")
    message("Specify 'TARGET_TOOLCHAIN_DIR' or put toolchain in '${TARGET_TOOLCHAIN_DIR}'")
    message(FATAL_ERROR "")
endif()

# make sure exe suffix is set for windows
if(NOT CMAKE_HOST_EXECUTABLE_SUFFIX)
    if(WIN32)
        set(CMAKE_HOST_EXECUTABLE_SUFFIX ".exe")
    endif()
endif()


# enable crosscompilation
set(CMAKE_SYSTEM_NAME       Generic)
set(CMAKE_SYSTEM_VERSION    1)
set(CMAKE_CROSSCOMPILING    TRUE)

# specify the cross compiler
set(CMAKE_SYSTEM_PROCESSOR  ${TARGET_ARCH})
set(CMAKE_C_COMPILER        ${TARGET_TOOLCHAIN_DIR}/bin/${TARGET_TOOLCHAIN}-gcc${CMAKE_HOST_EXECUTABLE_SUFFIX})
set(CMAKE_CXX_COMPILER      ${TARGET_TOOLCHAIN_DIR}/bin/${TARGET_TOOLCHAIN}-g++${CMAKE_HOST_EXECUTABLE_SUFFIX})

# skip checking compiler
set(CMAKE_C_COMPILER_WORKS      1)
set(CMAKE_CXX_COMPILER_WORKS    1)

# intended for cross-compiling
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)


# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM  NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE  ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY  ONLY)


# use relative path
set(CMAKE_USE_RELATIVE_PATHS  ON)

