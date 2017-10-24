
########################################################################
# relative source path defined by __FILENAME__
########################################################################

set(CMAKE_CXX_FLAGS     "${CMAKE_CXX_FLAGS} -D__FILENAME__='\"$(subst ${CMAKE_SOURCE_DIR}/,,$(abspath $<))\"'")
set(CMAKE_C_FLAGS       "${CMAKE_C_FLAGS}   -D__FILENAME__='\"$(subst ${CMAKE_SOURCE_DIR}/,,$(abspath $<))\"'")

