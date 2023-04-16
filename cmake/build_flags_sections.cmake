
########################################################################
# strip unused sections
########################################################################

set(CMAKE_CXX_FLAGS             "${CMAKE_CXX_FLAGS}  -ffunction-sections -fdata-sections")
set(CMAKE_C_FLAGS               "${CMAKE_C_FLAGS}    -ffunction-sections -fdata-sections")
set(CMAKE_EXE_LINKER_FLAGS      "${CMAKE_EXE_LINKER_FLAGS} -Wl,--gc-sections")

