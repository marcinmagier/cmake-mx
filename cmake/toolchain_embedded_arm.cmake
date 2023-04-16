
########################################################################
# Set up cross compiler tools
########################################################################


set(TARGET_ARCH             arm)
set(TARGET_TOOLCHAIN        arm-none-eabi)

if(NOT TARGET_TOOLCHAIN_DIR)
    set(TARGET_TOOLCHAIN_DIR    /opt/toolchain/${TARGET_TOOLCHAIN})
endif()
if(NOT EXISTS ${TARGET_TOOLCHAIN_DIR})
    message("Toolchain directory not found.")
    message("Specify 'TARGET_TOOLCHAIN_DIR' or put toolchain in '${TARGET_TOOLCHAIN_DIR}'")
    message(FATAL_ERROR "")
endif()


# enable crosscompilation
set(CMAKE_SYSTEM_NAME       Linux)
set(CMAKE_SYSTEM_VERSION    1)
set(CMAKE_CROSSCOMPILING    TRUE)

# specify the cross compiler
set(CMAKE_SYSTEM_PROCESSOR  ${TARGET_ARCH})
set(CMAKE_C_COMPILER        ${TARGET_TOOLCHAIN_DIR}/bin/${TARGET_TOOLCHAIN}-gcc)
set(CMAKE_CXX_COMPILER      ${TARGET_TOOLCHAIN_DIR}/bin/${TARGET_TOOLCHAIN}-g++)
# skip checking compiler
set(CMAKE_C_COMPILER_WORKS      1)
set(CMAKE_CXX_COMPILER_WORKS    1)


# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM  NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE  ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY  ONLY)


# use relative path
set(CMAKE_USE_RELATIVE_PATHS  ON)

