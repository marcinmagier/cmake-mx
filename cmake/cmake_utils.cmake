
if(NOT CMAKE_BUILD_TARGET)
    execute_process(COMMAND uname -m OUTPUT_VARIABLE CMAKE_BUILD_TARGET)
endif()
if(NOT CMAKE_BUILD_VARIANT)
    set(CMAKE_BUILD_VARIANT  debug)
endif()


########################################################################
# helper functions to include sub cmake lists
########################################################################

macro(INCLUDE_CONDITIONAL filename)
    set(included FALSE)
    set(defaultfile "${ARGN}")
    if("${defaultfile}" STREQUAL "")
        set(defaultfile all)
    endif()
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${filename}.${CMAKE_BUILD_VARIANT}.cmake")
        include("${filename}.${CMAKE_BUILD_VARIANT}.cmake")
        set(included TRUE)
    endif()
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${filename}.${defaultfile}.${CMAKE_BUILD_VARIANT}.cmake")
        include("${filename}.${defaultfile}.${CMAKE_BUILD_VARIANT}.cmake")
        set(included TRUE)
    endif()
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${filename}.${CMAKE_BUILD_TARGET}.cmake")
        include("${filename}.${CMAKE_BUILD_TARGET}.cmake")
        set(included TRUE)
    endif()
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${filename}.${defaultfile}.${CMAKE_BUILD_TARGET}.cmake")
        include("${filename}.${defaultfile}.${CMAKE_BUILD_TARGET}.cmake")
        set(included TRUE)
    endif()
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${filename}.${CMAKE_BUILD_VARIANT}.${CMAKE_BUILD_TARGET}.cmake")
        include("${filename}.${CMAKE_BUILD_VARIANT}.${CMAKE_BUILD_TARGET}.cmake")
        set(included TRUE)
    endif()
    if(NOT ${included})
        if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${filename}.${defaultfile}.cmake")
            include("${filename}.${defaultfile}.cmake")
        endif()
    endif()
    unset(defaultfiles)
    unset(included)
endmacro()

