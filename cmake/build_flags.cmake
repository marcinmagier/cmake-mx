
########################################################################
# setup default configuration
########################################################################

if(NOT CMAKE_COMMON_FLAGS_DEBUG)
    set(CMAKE_COMMON_FLAGS_DEBUG  "-g -O0")
endif()

set(CMAKE_C_FLAGS_DEBUG         ${CMAKE_COMMON_FLAGS_DEBUG})
set(CMAKE_CXX_FLAGS_DEBUG       ${CMAKE_COMMON_FLAGS_DEBUG})
set(CMAKE_ASM_FLAGS_DEBUG       ${CMAKE_COMMON_FLAGS_DEBUG})



if(NOT CMAKE_COMMON_FLAGS_RELEASE)
    set(CMAKE_COMMON_FLAGS_RELEASE  "-O2")
endif()

set(CMAKE_C_FLAGS_RELEASE       ${CMAKE_COMMON_FLAGS_RELEASE})
set(CMAKE_CXX_FLAGS_RELEASE     ${CMAKE_COMMON_FLAGS_RELEASE})
set(CMAKE_ASM_FLAGS_RELEASE     ${CMAKE_COMMON_FLAGS_RELEASE})

