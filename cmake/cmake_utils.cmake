
if(NOT CMAKE_BUILD_TARGET)
    execute_process(COMMAND uname -m OUTPUT_VARIABLE CMAKE_BUILD_TARGET)
endif()
if(NOT CMAKE_BUILD_VARIANT)
    set(CMAKE_BUILD_VARIANT  debug)
endif()



########################################################################
# helper function to parse conditional arguments
########################################################################

# Parse conditional arguments (IF_Y, IF_M, IF) and a custom values key
# Usage: parse_conditional_args(<prefix> <key> [args...])
# Sets in PARENT_SCOPE:
#   <prefix>_CONDITION - TRUE if condition met, FALSE otherwise
#   <prefix>_VALUES    - list of values from the key argument
#
# Example:
#   parse_conditional_args(ARG "CFLAGS" ${ARGN})
#   if(NOT ARG_CONDITION)
#       return()
#   endif()
#   # use ${ARG_VALUES}
#
function(PARSE_CONDITIONAL_ARGS prefix key)
    set(condition FALSE)

    set(options "")
    set(single IF_Y IF_M)
    set(multi IF "${key}")
    cmake_parse_arguments(PARSE "${options}" "${single}" "${multi}" ${ARGN})

    # backward compatibility: if no conditional args, treat unparsed as values
    if(NOT (PARSE_IF_Y OR PARSE_IF_M OR PARSE_IF OR PARSE_${key}))
        set(PARSE_${key} ${PARSE_UNPARSED_ARGUMENTS})
        set(condition TRUE)
    endif()

    while(1)
        if(PARSE_IF_Y)
            if(DEFINED "${PARSE_IF_Y}")
                set(PARSE_IF_Y "${${PARSE_IF_Y}}")
            endif()
            if("${PARSE_IF_Y}" STREQUAL "y")
                set(condition TRUE)
                break()
            endif()
        endif()
        if(PARSE_IF_M)
            if(DEFINED "${PARSE_IF_M}")
                set(PARSE_IF_M "${${PARSE_IF_M}}")
            endif()
            if("${PARSE_IF_M}" STREQUAL "m")
                set(condition TRUE)
                break()
            endif()
        endif()

        if(PARSE_IF)
            string(JOIN " " expression "${PARSE_IF}")
            if(${expression})
                set(condition TRUE)
            endif()
            break()
        endif()

        break()
    endwhile()

    set(${prefix}_CONDITION ${condition} PARENT_SCOPE)
    set(${prefix}_VALUES ${PARSE_${key}} PARENT_SCOPE)
endfunction()



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



########################################################################
# helper functions to add conditional subdirectories
########################################################################

macro(ADD_CONDITIONAL subdir)
    parse_conditional_args(ARG "" ${ARGN})
    if(ARG_CONDITION)
        add_subdirectory(${subdir})
    endif()
endmacro()
