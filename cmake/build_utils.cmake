
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

# add source files
function(ADD_SOURCES target)
    set(target_srcs "${target}_SRCS")
    # get current sources list, define if necessary
    get_property(is_defined GLOBAL PROPERTY "${target_srcs}" DEFINED)
    if(NOT is_defined)
        define_property(GLOBAL PROPERTY "${target_srcs}"
                        BRIEF_DOCS "${target} sources"
                        FULL_DOCS "List of source files to be compiled into ${target}")
    endif()

    foreach(src IN LISTS ARGN)
        # find apsolute source path
        if(NOT IS_ABSOLUTE "${src}")
            get_filename_component(src "${src}" ABSOLUTE)
        endif()
        # append source path
        set_property(GLOBAL APPEND PROPERTY "${target_srcs}" "${src}")
    endforeach()
endfunction()

function(ADD_LIB_SOURCES)
    add_sources(${PRJ_LIB_NAME} ${ARGN})
endfunction()

function(ADD_APP_SOURCES)
    add_sources(${PRJ_APP_NAME} ${ARGN})
endfunction()


# add source file and private defines for the file
function(ADD_SOURCE target src)
    set(target_srcs "${target}_SRCS")
    # get current sources list, define if necessary
    get_property(is_defined GLOBAL PROPERTY "${target_srcs}" DEFINED)
    if(NOT is_defined)
        define_property(GLOBAL PROPERTY "${target_srcs}"
                        BRIEF_DOCS "${target} sources"
                        FULL_DOCS "List of source files to be compiled into ${target}")
    endif()

    foreach(def IN LISTS ARGN)
        set(defs "${def} ${defs}")
    endforeach()

    if(NOT IS_ABSOLUTE "${src}")
        get_filename_component(src "${src}" ABSOLUTE)
    endif()
    # append source path
    set_property(GLOBAL APPEND PROPERTY "${target_srcs}" "${src} ${defs}")
endfunction()

function(ADD_LIB_SOURCE)
    add_source(${PRJ_LIB_NAME} ${ARGN})
endfunction()

function(ADD_APP_SOURCE)
    add_source(${PRJ_APP_NAME} ${ARGN})
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

# setup private defines for each source file
macro(SET_PRIVATE_DEFINES target)
    get_property(sources GLOBAL PROPERTY "${target}_SRCS")
    foreach(src IN LISTS sources)
        string(REPLACE " " ";" def_list ${src})
        list(GET def_list 0 src)
        list(REMOVE_AT def_list 0)
        string(REPLACE ";" " " defs "${def_list}")
        # find relative source path
        file(RELATIVE_PATH relsrc "${CMAKE_CURRENT_SOURCE_DIR}" "${src}")
        set_source_files_properties( ${src} PROPERTIES COMPILE_FLAGS "${defs}")
    endforeach()
endmacro()




########################################################################
# helper functions to add includes
########################################################################

function(ADD_INCLUDES target)
    set(target_incs "${target}_INCS")
    # get current includes list, define if necessary
    get_property(is_defined GLOBAL PROPERTY "${target_incs}" DEFINED)
    if(NOT is_defined)
        define_property(GLOBAL PROPERTY "${target_incs}"
                        BRIEF_DOCS "${target} includes"
                        FULL_DOCS "List of include directories for ${target}")
    endif()

    foreach(inc IN LISTS ARGN)
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
    set(target_hdrs "${target}_HDRS")
    # get current headers list, define if necessary
    get_property(is_defined GLOBAL PROPERTY "${target_hdrs}" DEFINED)
    if(NOT is_defined)
        define_property(GLOBAL PROPERTY "${target_hdrs}"
                        BRIEF_DOCS "${target} headers"
                        FULL_DOCS "List of exported headers for ${target}")
    endif()

    foreach(hdr IN LISTS ARGN)
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
    set(target_defs "${target}_DEFS")
    # get current defines list, define if necessary
    get_property(is_defined GLOBAL PROPERTY "${target_defs}" DEFINED)
    if(NOT is_defined)
        define_property(GLOBAL PROPERTY "${target_defs}"
                        BRIEF_DOCS "${target} defines"
                        FULL_DOCS "List of defines for ${target}")
    endif()

    foreach(def IN LISTS ARGN)
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
    set(target_cfgs "${target}_CFGS")
    # get current cflags list, define if necessary
    get_property(is_defined GLOBAL PROPERTY "${target_cfgs}" DEFINED)
    if(NOT is_defined)
        define_property(GLOBAL PROPERTY "${target_cfgs}"
                        BRIEF_DOCS "${target} cflags"
                        FULL_DOCS "List of cflags for ${target}")
    endif()

    foreach(cfg IN LISTS ARGN)
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

