cmake_minimum_required(VERSION 3.25)

project(fgof_fs VERSION 0.1.0 LANGUAGES Fortran C)

add_library(fgof_fs
  src/fgof_fs_types.f90
  src/fgof_fs_posix.f90
  src/fgof_path.f90
  src/fgof_fs.f90
  src/fgof_fs_posix.c
)
add_library(fgof::fs ALIAS fgof_fs)

set_target_properties(fgof_fs PROPERTIES
  Fortran_MODULE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/mod"
)

target_include_directories(fgof_fs PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/mod>
)

target_compile_options(fgof_fs PRIVATE
  $<$<COMPILE_LANG_AND_ID:Fortran,GNU>:-std=f2018 -Wall -Wextra -Wpedantic -Werror>
  $<$<COMPILE_LANG_AND_ID:C,GNU,Clang,AppleClang>:-Wall -Wextra -Wpedantic -Werror>
)
