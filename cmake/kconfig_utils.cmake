

function(IMPORT_KCONFIG filepath)
    if(NOT EXISTS "${filepath}")
        message(ERROR "auto.conf not found: ${filepath}")
        return()
    endif()

    file(STRINGS "${filepath}" lines)

    foreach(line IN LISTS lines)
        # Skip comments and empty lines
        if(line MATCHES "^[ \t]*#" OR line STREQUAL "")
            continue()
        endif()

        # Handle "CONFIG_X is not set"
        if(line MATCHES "^(CONFIG_[A-Za-z0-9_]+) is not set")
            set(var "${CMAKE_MATCH_1}")
            # set(${var} "n" PARENT_SCOPE)
            continue()
        endif()

        # Handle normal assignments: CONFIG_X=...
        if(line MATCHES "^(CONFIG_[A-Za-z0-9_]+)=(.*)")
            set(var "${CMAKE_MATCH_1}")
            set(val "${CMAKE_MATCH_2}")

            # Remove surrounding quotes if present
            if(val MATCHES "^\"(.*)\"$")
                set(val "${CMAKE_MATCH_1}")
            endif()

            set(${var} "${val}" PARENT_SCOPE)
        endif()
    endforeach()
endfunction()
