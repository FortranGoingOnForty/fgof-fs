module fgof_fs_types
  use iso_fortran_env, only : int64
  implicit none
  private

  public :: directory_entry
  public :: path_info

  type :: path_info
    logical :: exists = .false.
    logical :: is_file = .false.
    logical :: is_directory = .false.
    logical :: is_symlink = .false.
    integer :: mode = -1
    integer(int64) :: size = -1_int64
  end type path_info

  type :: directory_entry
    character(len=:), allocatable :: name
    character(len=:), allocatable :: path
    integer :: depth = 0
    type(path_info) :: info
  end type directory_entry

end module fgof_fs_types
