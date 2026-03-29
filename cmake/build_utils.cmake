
# include_guard(GLOBAL)

# include(cmake_utils)


########################################################################
# define useful permissions
########################################################################

set(LIB_STATIC_PERMISSIONS  OWNER_READ OWNER_WRITE OWNER_EXECUTE
                            GROUP_READ GROUP_EXECUTE
                            WORLD_READ WORLD_EXECUTE)

set(LIB_SHARED_PERMISSIONS  OWNER_READ OWNER_WRITE OWNER_EXECUTE
                            GROUP_READ GROUP_EXECUTE
                            WORLD_READ WORLD_EXECUTE)

set(APP_PERMISSIONS  OWNER_READ OWNER_WRITE OWNER_EXECUTE
                     GROUP_READ GROUP_EXECUTE
                     WORLD_READ WORLD_EXECUTE)



########################################################################
# helper functions to add sources
########################################################################

# add source file and private cflags for the file
function(ADD_SOURCE target src)
    parse_conditional_args(ARG "CFLAGS" ${ARGN})
    if(NOT ARG_CONDITION)
        return()
    endif()

    set(target_srcs "${target}_SRCS")
    # get current sources list, define if necessary
    get_property(is_defined GLOBAL PROPERTY "${target_srcs}" DEFINED)
    if(NOT is_defined)
        define_property(GLOBAL PROPERTY "${target_srcs}"
                        BRIEF_DOCS "${target} sources"
                        FULL_DOCS "List of source files to be compiled into ${target}")
    endif()

    foreach(cflag IN LISTS ARG_VALUES)
        set(cflags "${cflag} ${cflags}")
    endforeach()

    if(NOT IS_ABSOLUTE "${src}")
        get_filename_component(src "${src}" ABSOLUTE)
    endif()
    # append source path
    if(EXISTS "${src}")
        set_property(GLOBAL APPEND PROPERTY "${target_srcs}" "${src} ${cflags}")
    else()
        message(WARNING "Source file not found: ${src}")
    endif()
endfunction()

function(ADD_LIB_SOURCE)
    add_source(${PRJ_LIB_NAME} ${ARGN})
endfunction()

function(ADD_APP_SOURCE)
    add_source(${PRJ_APP_NAME} ${ARGN})
endfunction()

# add source files with glob/regex support
function(ADD_SOURCES_EX target)
    foreach(pattern IN LISTS ARGN)
        # convert relative patterns to absolute
        if(NOT IS_ABSOLUTE "${pattern}")
            set(pattern "${CMAKE_CURRENT_SOURCE_DIR}/${pattern}")
        endif()

        # check for recursive pattern
        if("${pattern}" MATCHES "\\*\\*/")
            string(REPLACE "**/" "" recursive_pattern "${pattern}")
            file(GLOB_RECURSE matched_files CONFIGURE_DEPENDS "${recursive_pattern}")
        else()
            file(GLOB matched_files CONFIGURE_DEPENDS "${pattern}")
        endif()

        if(matched_files)
            foreach(src IN LISTS matched_files)
                add_source("${target}" "${src}")
            endforeach()
        else()
            message(WARNING "No files match with pattern: ${pattern}")
        endif()
    endforeach()
endfunction()

function(ADD_LIB_SOURCES_EX)
    add_sources_ex(${PRJ_LIB_NAME} ${ARGN})
endfunction()

function(ADD_APP_SOURCES_EX)
    add_sources_ex(${PRJ_APP_NAME} ${ARGN})
endfunction()

# add source files
function(ADD_SOURCES target)
    parse_conditional_args(ARG "SOURCES" ${ARGN})
    if(NOT ARG_CONDITION)
        return()
    endif()

    foreach(src IN LISTS ARG_VALUES)
        if("${src}" MATCHES "[*?[]")
            add_sources_ex(${target} "${src}")
        else()
            add_source("${target}" "${src}")
        endif()
    endforeach()
endfunction()

function(ADD_LIB_SOURCES)
    add_sources(${PRJ_LIB_NAME} ${ARGN})
endfunction()

function(ADD_APP_SOURCES)
    add_sources(${PRJ_APP_NAME} ${ARGN})
endfunction()

# retrieve source files
function(GET_SOURCES result)
    set(srclist)
    foreach(target IN LISTS ARGN)
        get_property(sources GLOBAL PROPERTY "${target}_SRCS")
        foreach(src IN LISTS sources)
            string(REPLACE " " ";" srcdefs ${src})
            list(GET srcdefs 0 src)
            # find relative source path
            file(RELATIVE_PATH relsrc "${CMAKE_CURRENT_SOURCE_DIR}" "${src}")
            list(APPEND srclist "${relsrc}")
        endforeach()
    endforeach()
    set(${result} ${srclist} PARENT_SCOPE)
endfunction()

# setup private cflags for each source file
macro(SET_PRIVATE_CFLAGS target)
    get_property(sources GLOBAL PROPERTY "${target}_SRCS")
    foreach(src IN LISTS sources)
        string(REPLACE " " ";" cflags_list ${src})
        list(GET cflags_list 0 src)
        list(REMOVE_AT cflags_list 0)
        string(REPLACE ";" " " cflags "${cflags_list}")
        set_source_files_properties( ${src} PROPERTIES COMPILE_FLAGS "${cflags}")
    endforeach()
endmacro()

# Add preprocessor define __FILENAME__ with relative source path for each source file
function(SET_FILENAME_DEFINES target)
    get_target_property(sources "${target}" SOURCES)
    foreach(src ${sources})
        set_property(SOURCE "${src}" APPEND PROPERTY COMPILE_DEFINITIONS "__FILENAME__=\"${src}\"")
    endforeach()
endfunction()




########################################################################
# helper functions to add includes
########################################################################

function(ADD_INCLUDES target)
    parse_conditional_args(ARG "INCLUDES" ${ARGN})
    if(NOT ARG_CONDITION)
        return()
    endif()

    set(target_incs "${target}_INCS")
    # get current includes list, define if necessary
    get_property(is_defined GLOBAL PROPERTY "${target_incs}" DEFINED)
    if(NOT is_defined)
        define_property(GLOBAL PROPERTY "${target_incs}"
                        BRIEF_DOCS "${target} includes"
                        FULL_DOCS "List of include directories for ${target}")
    endif()

    foreach(inc IN LISTS ARG_VALUES)
        # find apsolute include path
        if(NOT IS_ABSOLUTE "${inc}")
            get_filename_component(inc "${inc}" ABSOLUTE)
        endif()
        # append include path
        set_property(GLOBAL APPEND PROPERTY "${target_incs}" "${inc}")
    endforeach()
endfunction()

function(ADD_LIB_INCLUDES)
    add_includes(${PRJ_LIB_NAME} ${ARGN})
endfunction()

function(ADD_APP_INCLUDES)
    add_includes(${PRJ_APP_NAME} ${ARGN})
endfunction()


function(GET_INCLUDES result)
    set(inclist)
    foreach(target IN LISTS ARGN)
        get_property(includes GLOBAL PROPERTY "${target}_INCS")
        foreach(inc IN LISTS includes)
            if("${inc}" MATCHES "^/usr/include/.*")
                # system include path
                list(APPEND inclist "${inc}")
            else()
                # find relative include path
                file(RELATIVE_PATH relinc "${CMAKE_CURRENT_SOURCE_DIR}" "${inc}")
                list(APPEND inclist "${relinc}")
            endif()
        endforeach()
    endforeach()
    set(${result} ${inclist} PARENT_SCOPE)
endfunction()




########################################################################
# helper functions to add headers
########################################################################

function(ADD_HEADERS target)
    parse_conditional_args(ARG "HEADERS" ${ARGN})
    if(NOT ARG_CONDITION)
        return()
    endif()

    set(target_hdrs "${target}_HDRS")
    # get current headers list, define if necessary
    get_property(is_defined GLOBAL PROPERTY "${target_hdrs}" DEFINED)
    if(NOT is_defined)
        define_property(GLOBAL PROPERTY "${target_hdrs}"
                        BRIEF_DOCS "${target} headers"
                        FULL_DOCS "List of exported headers for ${target}")
    endif()

    foreach(hdr IN LISTS ARG_VALUES)
        # find apsolute include path
        if(NOT IS_ABSOLUTE "${hdr}")
            get_filename_component(hdr "${hdr}" ABSOLUTE)
        endif()
        # append include path
        set_property(GLOBAL APPEND PROPERTY "${target_hdrs}" "${hdr}")
    endforeach()
endfunction()

function(ADD_LIB_HEADERS)
    add_headers(${PRJ_LIB_NAME} ${ARGN})
endfunction()

function(ADD_APP_HEADERS)
    add_headers(${PRJ_APP_NAME} ${ARGN})
endfunction()


function(GET_HEADERS result)
    set(hdrlist)
    foreach(target IN LISTS ARGN)
        get_property(headers GLOBAL PROPERTY "${target}_HDRS")
        foreach(hdr IN LISTS headers)
            # find relative include path
            file(RELATIVE_PATH relinc "${CMAKE_CURRENT_SOURCE_DIR}" "${hdr}")
            list(APPEND hdrlist "${relinc}")
        endforeach()
    endforeach()
    set(${result} ${hdrlist} PARENT_SCOPE)
endfunction()




########################################################################
# helper functions to add defines
########################################################################

function(ADD_DEFINES target)
    parse_conditional_args(ARG "DEFINES" ${ARGN})
    if(NOT ARG_CONDITION)
        return()
    endif()

    set(target_defs "${target}_DEFS")
    # get current defines list, define if necessary
    get_property(is_defined GLOBAL PROPERTY "${target_defs}" DEFINED)
    if(NOT is_defined)
        define_property(GLOBAL PROPERTY "${target_defs}"
                        BRIEF_DOCS "${target} defines"
                        FULL_DOCS "List of defines for ${target}")
    endif()

    foreach(def IN LISTS ARG_VALUES)
        # append define
        set_property(GLOBAL APPEND PROPERTY "${target_defs}" "${def}")
    endforeach()
endfunction()

function(ADD_LIB_DEFINES)
    add_defines(${PRJ_LIB_NAME} ${ARGN})
endfunction()

function(ADD_APP_DEFINES)
    add_defines(${PRJ_APP_NAME} ${ARGN})
endfunction()


function(GET_DEFINES result)
    set(deflist)
    foreach(target IN LISTS ARGN)
        get_property(defines GLOBAL PROPERTY "${target}_DEFS")
        foreach(def IN LISTS defines)
            list(APPEND deflist "${def}")
        endforeach()
    endforeach()
    set(${result} ${deflist} PARENT_SCOPE)
endfunction()




########################################################################
# helper functions to add cflags
########################################################################

function(ADD_CFLAGS target)
    parse_conditional_args(ARG "CFLAGS" ${ARGN})
    if(NOT ARG_CONDITION)
        return()
    endif()

    set(target_cfgs "${target}_CFGS")
    # get current cflags list, define if necessary
    get_property(is_defined GLOBAL PROPERTY "${target_cfgs}" DEFINED)
    if(NOT is_defined)
        define_property(GLOBAL PROPERTY "${target_cfgs}"
                        BRIEF_DOCS "${target} cflags"
                        FULL_DOCS "List of cflags for ${target}")
    endif()

    foreach(cfg IN LISTS ARG_VALUES)
        # append define
        set_property(GLOBAL APPEND_STRING PROPERTY "${target_cfgs}" "${cfg} ")
    endforeach()
endfunction()

function(ADD_LIB_CFLAGS)
    add_cflags(${PRJ_LIB_NAME} ${ARGN})
endfunction()

function(ADD_APP_CFLAGS)
    add_cflags(${PRJ_APP_NAME} ${ARGN})
endfunction()


function(GET_CFLAGS result)
    set(cfglist "")
    foreach(target IN LISTS ARGN)
        get_property(cflags GLOBAL PROPERTY "${target}_CFGS")
        foreach(cfg IN LISTS cflags)
            set(cfglist "${cfglist} ${cfg}")
        endforeach()
    endforeach()
    set(${result} ${cfglist} PARENT_SCOPE)
endfunction()




########################################################################
# other functions
########################################################################

# Add preprocessor define __FILENAME__ with relative source path
# for each source file depended on given target
function(DEFINE_FILENAME_FOR_SOURCES target)
    get_target_property(sources "${target}" SOURCES)
    foreach(src ${sources})
        set_property(SOURCE "${src}" APPEND PROPERTY COMPILE_DEFINITIONS "__FILENAME__=\"${src}\"")
    endforeach()
endfunction()

