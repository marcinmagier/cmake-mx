
include(CMakeParseArguments)



# PREPARE_KCONFIG(defconfig_file [CONFIG_FILE <path>])
#
# Ensure a project has a usable configuration file by copying the default/seed
# defconfig into the build tree when no .config exists yet.
#
# Arguments:
#   defconfig_file - Path to the default configuration file.
#   CONFIG_FILE    - Optional explicit output path. Defaults to ${CMAKE_BINARY_DIR}/.config.
#
function(PREPARE_KCONFIG defconfig_file)
    set(options)
    set(one_value_args CONFIG_FILE)
    set(multi_value_args)

    cmake_parse_arguments(
        ARG
        "${options}"
        "${one_value_args}"
        "${multi_value_args}"
        ${ARGN}
    )

    if(ARG_CONFIG_FILE)
        set(config_file "${ARG_CONFIG_FILE}")
    else()
        set(config_file "${CMAKE_BINARY_DIR}/.config")
    endif()

    if(NOT EXISTS "${defconfig_file}")
        message(FATAL_ERROR "Kconfig default configuration not found: ${defconfig_file}")
    endif()

    if(NOT EXISTS "${config_file}")
        file(COPY_FILE "${defconfig_file}" "${config_file}")
    endif()
endfunction()


# IMPORT_KCONFIG([CONFIG_FILE <path>])
#
# Parse a .config file and export any CONFIG_* entries into the parent scope.
#
# Arguments:
#   CONFIG_FILE - Optional config path. Defaults to ${CMAKE_BINARY_DIR}/.config.
function(IMPORT_KCONFIG)
    set(options)
    set(one_value_args CONFIG_FILE)
    set(multi_value_args)

    cmake_parse_arguments(
        ARG
        "${options}"
        "${one_value_args}"
        "${multi_value_args}"
        ${ARGN}
    )

    if(ARG_CONFIG_FILE)
        set(config_file "${ARG_CONFIG_FILE}")
    else()
        set(config_file "${CMAKE_BINARY_DIR}/.config")
    endif()

    if(NOT EXISTS "${config_file}")
        message(FATAL_ERROR "Kconfig configuration not found: ${config_file}")
    endif()

    file(STRINGS "${config_file}" lines)

    foreach(line IN LISTS lines)
        # Skip comments and empty lines
        if(line MATCHES "^[ \t]*#" OR line STREQUAL "")
            continue()
        endif()

        # Handle "CONFIG_X is not set"
        if(line MATCHES "^(CONFIG_[A-Za-z0-9_]+) is not set")
            # set(var "${CMAKE_MATCH_1}")
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


# GENERATE_KCONFIG(target [KCONFIG_FILE <path>] [CONFIG_FILE <path>]
#                  [HEADER_FILE <path>] [INCLUDE_HEADER])
#
# Run Kconfig generation for a given target.
#
# Arguments:
#   target          - CMake target that should depend on the generated configuration.
#   KCONFIG_FILE    - Path to the Kconfig source file. Defaults to ${CMAKE_BINARY_DIR}/Kconfig.
#   CONFIG_FILE     - Output config path. Defaults to ${CMAKE_BINARY_DIR}/.config.
#   HEADER_FILE     - Generated header path. Defaults to ${CMAKE_BINARY_DIR}/autoconf.h.
#   INCLUDE_HEADER  - Add the generated header to the compile command with -include.
#
function(GENERATE_KCONFIG target)
    set(options INCLUDE_HEADER)
    set(one_value_args KCONFIG_FILE CONFIG_FILE HEADER_FILE)
    set(multi_value_args)

    cmake_parse_arguments(
        ARG
        "${options}"
        "${one_value_args}"
        "${multi_value_args}"
        ${ARGN}
    )

    if(ARG_KCONFIG_FILE)
        set(kconfig_file "${ARG_KCONFIG_FILE}")
    else()
        set(kconfig_file "Kconfig")
    endif()

    if(ARG_CONFIG_FILE)
        set(config_file "${ARG_CONFIG_FILE}")
    else()
        set(config_file "${CMAKE_BINARY_DIR}/.config")
    endif()

    if(ARG_HEADER_FILE)
        set(header_file "${ARG_HEADER_FILE}")
    else()
        set(header_file "${CMAKE_BINARY_DIR}/autoconf.h")
    endif()

    find_program(KCONFIG_GENCONFIG genconfig REQUIRED)

    add_custom_command(
        OUTPUT "${header_file}"
        COMMAND "${KCONFIG_GENCONFIG}"
            --header-path "${header_file}"
            --config-out "${config_file}"
            "${kconfig_file}"
        DEPENDS
            "${kconfig_file}"
            "${config_file}"
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        VERBATIM
    )

    add_custom_target(
        generate_kconfig
        DEPENDS "${header_file}"
    )

    add_dependencies("${target}" generate_kconfig)

    if(ARG_INCLUDE_HEADER)
        target_compile_options("${target}" PRIVATE
            "-include"
            "${header_file}"
        )
    endif()
endfunction()
