
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

macro(GEN_OUT_SIZE target)
    get_filename_component(target_name ${target} NAME_WE)
    get_target_property(target_output ${target} OUTPUT_NAME)

    #print the size information
    add_custom_command(
        OUTPUT ${target_name}_size DEPENDS ${target}
        COMMAND ${SIZE} --format=berkeley ${target_output}
    )

    #add a top level target for output files
    add_custom_target(
        ${target_name}_out_size ALL DEPENDS ${target_name}_size
    )
endmacro(GEN_OUT_SIZE)


macro(GEN_OBJECTS_SIZE target)
    get_filename_component(target_name ${target} NAME_WE)

    get_target_property(sources ${target} SOURCES)
    set(objects)
    foreach(src IN LISTS sources)
        list(APPEND objects "CMakeFiles/${target}.dir/${src}${CMAKE_C_OUTPUT_EXTENSION}")
    endforeach()

    #print the size information
    add_custom_command(
        OUTPUT ${target_name}_obj_size DEPENDS ${target}
        COMMAND ${SIZE} --format=berkeley --totals ${objects}
    )

    #add a top level target for output files
    add_custom_target(
        ${target_name}_out_obj_size ALL DEPENDS ${target_name}_obj_size
    )
endmacro(GEN_OBJECTS_SIZE)




########################################################################
# helper functions to build output formats
########################################################################

macro(GEN_OUT_FORMATS target)
    get_filename_component(target_name ${target} NAME_WE)
    get_target_property(target_output ${target} OUTPUT_NAME)

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

    #command to create a rom from bin
    add_custom_command(
        OUTPUT ${target_name}.rom DEPENDS ${target_name}.bin
        COMMAND ${HEXDUMP} -v -e'1/1 \"%.2X\\n\"' ${target_name}.bin > ${target_name}.rom
    )

    #add a top level target for output files
    add_custom_target(
        ${target_name}_out_formats ALL DEPENDS ${target_name}.bin ${target_name}.hex ${target_name}.rom
    )
endmacro(GEN_OUT_FORMATS)




########################################################################
# helper functions to build output linstings
########################################################################

macro(GEN_OUT_LISTING target)
    get_filename_component(target_name ${target} NAME_WE)
    get_target_property(target_output ${target} OUTPUT_NAME)

    #command to create a lss from elf
    add_custom_command(
        OUTPUT ${target_name}.lss DEPENDS ${target}
        COMMAND ${OBJDUMP} -S ${target_output} > ${target_name}.lss
    )

    #command to create a dmp from elf
    add_custom_command(
        OUTPUT ${target_name}.dmp DEPENDS ${target}
        COMMAND ${OBJDUMP} -x --syms ${target_output} > ${target_name}.dmp
    )

    #command to create a dump from elf
    add_custom_command(
        OUTPUT ${target_name}.dump DEPENDS ${target}
        COMMAND ${OBJDUMP} -DSC ${target_output} > ${target_name}.dump
    )

    #add a top level target for output files
    add_custom_target(
        ${target_name}_out_listing ALL DEPENDS ${target_name}.lss ${target_name}.dmp ${target_name}.dump
    )
endmacro(GEN_OUT_LISTING)




