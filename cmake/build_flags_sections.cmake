
########################################################################
# strip unused sections
########################################################################

set(CMAKE_CXX_FLAGS_RELEASE     "${CMAKE_CXX_FLAGS_RELEASE}  -ffunction-sections -fdata-sections")
set(CMAKE_C_FLAGS_RELEASE       "${CMAKE_C_FLAGS_RELEASE}    -ffunction-sections -fdata-sections")
set(CMAKE_EXE_LINKER_FLAGS      "${CMAKE_LINK_FLAGS_RELEASE} -Wl,--gc-sections")

