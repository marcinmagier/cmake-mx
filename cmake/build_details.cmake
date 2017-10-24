
########################################################################
# rules to compile objects
# generate detailed listing for every compiled object
########################################################################

set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   -save-temps")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -save-temps")


set(CMAKE_C_COMPILE_OBJECT
  "<CMAKE_C_COMPILER> <DEFINES> <INCLUDES> <FLAGS> -Wa,-ahlms=<OBJECT>.lst -o <OBJECT>   -c <SOURCE>")

set(CMAKE_CXX_COMPILE_OBJECT
  "<CMAKE_CXX_COMPILER>  <DEFINES> <INCLUDES> <FLAGS> -Wa,-ahlms=<OBJECT>.lst -o <OBJECT>   -c <SOURCE>")

set(CMAKE_ASM${ASM_DIALECT}_COMPILE_OBJECT
  "<CMAKE_ASM${ASM_DIALECT}_COMPILER> <DEFINES> <INCLUDES> <FLAGS> -Wa,-amhls=<OBJECT>.lst -o <OBJECT>   -c <SOURCE>")

