
########################################################################
# programs for output files
########################################################################

if(NOT TARGET_TOOLCHAIN)
    get_property(TARGET_TOOLCHAIN GLOBAL PROPERTY "TARGET_TOOLCHAIN")
    if(NOT TARGET_TOOLCHAIN)
        message( FATAL_ERROR "Toolchain not specified")
    endif()
endif()

find_program(LINKER     ${TARGET_TOOLCHAIN_DIR}/bin/${TARGET_TOOLCHAIN}-ld)
find_program(OBJCOPY    ${TARGET_TOOLCHAIN_DIR}/bin/${TARGET_TOOLCHAIN}-objcopy)
find_program(OBJDUMP    ${TARGET_TOOLCHAIN_DIR}/bin/${TARGET_TOOLCHAIN}-objdump)
find_program(GDB        ${TARGET_TOOLCHAIN_DIR}/bin/${TARGET_TOOLCHAIN}-gdb)
find_program(SIZE       ${TARGET_TOOLCHAIN_DIR}/bin/${TARGET_TOOLCHAIN}-size)
find_program(HEXDUMP    hexdump)
find_program(OPENOCD    openocd)




########################################################################
# helper functions to show output size
########################################################################

macro(SHOW_SIZE target)
    get_filename_component(target_name ${target} NAME_WE)
    get_target_property(target_output ${target} OUTPUT_NAME)
    if(CMAKE_EXECUTABLE_SUFFIX)
        set(target_output ${target_output}${CMAKE_EXECUTABLE_SUFFIX})
    endif()

    #print the size information
    add_custom_command(
        OUTPUT ${target_name}_size DEPENDS ${target}
        COMMAND ${SIZE} --format=berkeley ${target_output}
    )

    #add a top level target for output files
    add_custom_target(
        ${target_name}_out_size ALL DEPENDS ${target_name}_size
    )
endmacro(SHOW_SIZE)



########################################################################
# helper functions to show sections size
########################################################################

macro(SHOW_SECTIONS_SIZE target)
    get_filename_component(target_name ${target} NAME_WE)
    get_target_property(target_output ${target} OUTPUT_NAME)
    if(CMAKE_EXECUTABLE_SUFFIX)
        set(target_output ${target_output}${CMAKE_EXECUTABLE_SUFFIX})
    endif()

    #print the size information
    add_custom_command(
        OUTPUT ${target_name}_sections_size DEPENDS ${target}
        COMMAND ${SIZE} --format=sysv -x ${target_output}
    )

    #add a top level target for output files
    add_custom_target(
        ${target_name}_out_sections_size ALL DEPENDS ${target_name}_sections_size
    )
endmacro(SHOW_SECTIONS_SIZE)



########################################################################
# helper functions to show objects size
########################################################################

macro(SHOW_OBJECTS_SIZE target)
    get_filename_component(target_name ${target} NAME_WE)

    get_target_property(sources ${target} SOURCES)
    set(objects)
    foreach(src IN LISTS sources)
        list(APPEND objects "CMakeFiles/${target}.dir/${src}${CMAKE_C_OUTPUT_EXTENSION}")
    endforeach()

    #print the size information
    add_custom_command(
        OUTPUT ${target_name}_objects_size DEPENDS ${target}
        COMMAND ${SIZE} --format=berkeley --totals ${objects}
    )

    #add a top level target for output files
    add_custom_target(
        ${target_name}_out_objects_size ALL DEPENDS ${target_name}_objects_size
    )
endmacro(SHOW_OBJECTS_SIZE)





########################################################################
# helper functions to build output formats
########################################################################

macro(GEN_OUT_FORMATS target)
    get_filename_component(target_name ${target} NAME_WE)
    get_target_property(target_output ${target} OUTPUT_NAME)
    if(CMAKE_EXECUTABLE_SUFFIX)
        set(target_output ${target_output}${CMAKE_EXECUTABLE_SUFFIX})
    endif()

    #command to create a hex from elf
    add_custom_command(
        OUTPUT ${target_name}.hex DEPENDS ${target}
        COMMAND ${OBJCOPY} -O ihex ${target_output} ${target_name}.hex
    )

    #command to create a bin from elf
    add_custom_command(
        OUTPUT ${target_name}.bin DEPENDS ${target}
        COMMAND ${OBJCOPY} -O binary ${target_output} ${target_name}.bin
    )

    # #command to create a rom from bin
    # add_custom_command(
    #     OUTPUT ${target_name}.rom DEPENDS ${target_name}.bin
    #     COMMAND ${HEXDUMP} -v -e'1/1 \"%.2X\\n\"' ${target_name}.bin > ${target_name}.rom
    # )

    #add a top level target for output files
    add_custom_target(
        ${target_name}_out_formats ALL DEPENDS ${target_name}.bin ${target_name}.hex
    )
endmacro(GEN_OUT_FORMATS)



########################################################################
# helper functions to build output linsting
########################################################################

macro(GEN_OUT_LISTING target)
    get_filename_component(target_name ${target} NAME_WE)
    get_target_property(target_output ${target} OUTPUT_NAME)
    if(CMAKE_EXECUTABLE_SUFFIX)
        set(target_output ${target_output}${CMAKE_EXECUTABLE_SUFFIX})
    endif()

    #command to create a lss from elf
    add_custom_command(
        OUTPUT ${target_name}.lss DEPENDS ${target}
        COMMAND ${OBJDUMP} -C -S ${target_output} > ${target_name}.lss
    )

    #add a top level target for output files
    add_custom_target(
        ${target_name}_out_listing ALL DEPENDS ${target_name}.lss
    )
endmacro(GEN_OUT_LISTING)



########################################################################
# helper functions to build output symbols
########################################################################

macro(GEN_OUT_SYMS target)
    get_filename_component(target_name ${target} NAME_WE)
    get_target_property(target_output ${target} OUTPUT_NAME)
    if(CMAKE_EXECUTABLE_SUFFIX)
        set(target_output ${target_output}${CMAKE_EXECUTABLE_SUFFIX})
    endif()

    #command to create a dmp from elf
    add_custom_command(
        OUTPUT ${target_name}.syms DEPENDS ${target}
        COMMAND ${OBJDUMP} -x --syms ${target_output} > ${target_name}.syms
    )

    #add a top level target for output files
    add_custom_target(
        ${target_name}_out_syms ALL DEPENDS ${target_name}.syms
    )
endmacro(GEN_OUT_SYMS)



########################################################################
# helper functions to build output dump
########################################################################

macro(GEN_OUT_DUMP target)
    get_filename_component(target_name ${target} NAME_WE)
    get_target_property(target_output ${target} OUTPUT_NAME)
    if(CMAKE_EXECUTABLE_SUFFIX)
        set(target_output ${target_output}${CMAKE_EXECUTABLE_SUFFIX})
    endif()

    #command to create a dump from elf
    add_custom_command(
        OUTPUT ${target_name}.dump DEPENDS ${target}
        COMMAND ${OBJDUMP} -s ${target_output} > ${target_name}.dump
    )

    #add a top level target for output files
    add_custom_target(
        ${target_name}_out_dump ALL DEPENDS ${target_name}.dump
    )
endmacro(GEN_OUT_DUMP)

