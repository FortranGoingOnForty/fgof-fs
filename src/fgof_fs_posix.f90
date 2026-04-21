module fgof_fs_posix
  use iso_c_binding, only : c_char, c_int, c_long_long, c_null_char
  use iso_fortran_env, only : int64
  implicit none
  private

  integer(c_int), parameter, public :: S_IFMT = int(o'170000', c_int)
  integer(c_int), parameter, public :: S_IFREG = int(o'100000', c_int)
  integer(c_int), parameter, public :: S_IFDIR = int(o'040000', c_int)
  integer(c_int), parameter, public :: S_IFLNK = int(o'120000', c_int)

  public :: lstat_mode
  public :: lstat_size
  public :: stat_mode
  public :: stat_size

  interface
    function fgof_fs_lstat_mode(pathname) bind(C, name="fgof_fs_lstat_mode")
      import :: c_int, c_char
      character(kind=c_char), intent(in) :: pathname(*)
      integer(c_int) :: fgof_fs_lstat_mode
    end function fgof_fs_lstat_mode

    function fgof_fs_stat_mode(pathname) bind(C, name="fgof_fs_stat_mode")
      import :: c_int, c_char
      character(kind=c_char), intent(in) :: pathname(*)
      integer(c_int) :: fgof_fs_stat_mode
    end function fgof_fs_stat_mode

    function fgof_fs_stat_size(pathname) bind(C, name="fgof_fs_stat_size")
      import :: c_char, c_long_long
      character(kind=c_char), intent(in) :: pathname(*)
      integer(c_long_long) :: fgof_fs_stat_size
    end function fgof_fs_stat_size

    function fgof_fs_lstat_size(pathname) bind(C, name="fgof_fs_lstat_size")
      import :: c_char, c_long_long
      character(kind=c_char), intent(in) :: pathname(*)
      integer(c_long_long) :: fgof_fs_lstat_size
    end function fgof_fs_lstat_size
  end interface

contains

  integer function stat_mode(path) result(mode)
    character(len=*), intent(in) :: path
    character(kind=c_char), allocatable :: c_path(:)

    c_path = to_c_string(path)
    mode = int(fgof_fs_stat_mode(c_path))
  end function stat_mode

  integer function lstat_mode(path) result(mode)
    character(len=*), intent(in) :: path
    character(kind=c_char), allocatable :: c_path(:)

    c_path = to_c_string(path)
    mode = int(fgof_fs_lstat_mode(c_path))
  end function lstat_mode

  integer(int64) function stat_size(path) result(size_bytes)
    character(len=*), intent(in) :: path
    character(kind=c_char), allocatable :: c_path(:)

    c_path = to_c_string(path)
    size_bytes = fgof_fs_stat_size(c_path)
  end function stat_size

  integer(int64) function lstat_size(path) result(size_bytes)
    character(len=*), intent(in) :: path
    character(kind=c_char), allocatable :: c_path(:)

    c_path = to_c_string(path)
    size_bytes = fgof_fs_lstat_size(c_path)
  end function lstat_size

  function to_c_string(str) result(buf)
    character(len=*), intent(in) :: str
    character(kind=c_char), allocatable :: buf(:)
    integer :: i
    integer :: n

    n = len_trim(str)
    allocate(buf(n + 1))
    do i = 1, n
      buf(i) = str(i:i)
    end do
    buf(n + 1) = c_null_char
  end function to_c_string

end module fgof_fs_posix
