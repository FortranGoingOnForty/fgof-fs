module fgof_fs_posix
  use iso_c_binding, only : c_char, c_int, c_long_long, c_null_char
  use iso_fortran_env, only : int64
  implicit none
  private

  integer(c_int), parameter, public :: S_IFMT = int(o'170000', c_int)
  integer(c_int), parameter, public :: S_IFREG = int(o'100000', c_int)
  integer(c_int), parameter, public :: S_IFDIR = int(o'040000', c_int)
  integer(c_int), parameter, public :: S_IFLNK = int(o'120000', c_int)
  integer, parameter :: ENTRY_NAME_LEN = 256
  integer, parameter :: PATH_BUFFER_LEN = 4096

  public :: current_dir
  public :: lstat_mode
  public :: lstat_size
  public :: mkdir_if_needed
  public :: rename_path
  public :: rmdir_path
  public :: unlink_path
  public :: scandir_names
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

    function fgof_fs_getcwd(pathname, path_len) bind(C, name="fgof_fs_getcwd")
      import :: c_char, c_int
      character(kind=c_char), intent(out) :: pathname(*)
      integer(c_int), value :: path_len
      integer(c_int) :: fgof_fs_getcwd
    end function fgof_fs_getcwd

    function fgof_fs_scandir_count(pathname) bind(C, name="fgof_fs_scandir_count")
      import :: c_char, c_int
      character(kind=c_char), intent(in) :: pathname(*)
      integer(c_int) :: fgof_fs_scandir_count
    end function fgof_fs_scandir_count

    function fgof_fs_scandir_fill(pathname, names, max_entries, stride) bind(C, name="fgof_fs_scandir_fill")
      import :: c_char, c_int
      character(kind=c_char), intent(in) :: pathname(*)
      character(kind=c_char), intent(out) :: names(*)
      integer(c_int), value :: max_entries
      integer(c_int), value :: stride
      integer(c_int) :: fgof_fs_scandir_fill
    end function fgof_fs_scandir_fill

    function fgof_fs_mkdir_if_needed(pathname, mode) bind(C, name="fgof_fs_mkdir_if_needed")
      import :: c_char, c_int
      character(kind=c_char), intent(in) :: pathname(*)
      integer(c_int), value :: mode
      integer(c_int) :: fgof_fs_mkdir_if_needed
    end function fgof_fs_mkdir_if_needed

    function fgof_fs_unlink_path(pathname) bind(C, name="fgof_fs_unlink_path")
      import :: c_char, c_int
      character(kind=c_char), intent(in) :: pathname(*)
      integer(c_int) :: fgof_fs_unlink_path
    end function fgof_fs_unlink_path

    function fgof_fs_rmdir_path(pathname) bind(C, name="fgof_fs_rmdir_path")
      import :: c_char, c_int
      character(kind=c_char), intent(in) :: pathname(*)
      integer(c_int) :: fgof_fs_rmdir_path
    end function fgof_fs_rmdir_path

    function fgof_fs_rename_path(source, destination) bind(C, name="fgof_fs_rename_path")
      import :: c_char, c_int
      character(kind=c_char), intent(in) :: source(*)
      character(kind=c_char), intent(in) :: destination(*)
      integer(c_int) :: fgof_fs_rename_path
    end function fgof_fs_rename_path
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

  function current_dir() result(path)
    character(len=:), allocatable :: path
    character(kind=c_char) :: c_path(PATH_BUFFER_LEN)
    integer(c_int) :: success

    c_path = c_null_char
    success = fgof_fs_getcwd(c_path, int(PATH_BUFFER_LEN, c_int))
    if (success == 0) then
      path = ""
      return
    end if

    path = from_c_string(c_path)
  end function current_dir

  function scandir_names(path) result(names)
    character(len=*), intent(in) :: path
    character(len=:), allocatable :: names(:)
    character(kind=c_char), allocatable :: c_path(:)
    character(kind=c_char), allocatable :: c_names(:)
    integer(c_int) :: c_count
    integer(c_int) :: c_filled
    integer :: count
    integer :: i
    integer :: max_len

    c_path = to_c_string(path)
    c_count = fgof_fs_scandir_count(c_path)
    count = int(c_count)

    if (count <= 0) then
      allocate(character(len=1) :: names(0))
      return
    end if

    allocate(c_names(count * ENTRY_NAME_LEN))
    c_names = c_null_char

    c_filled = fgof_fs_scandir_fill(c_path, c_names, int(count, c_int), int(ENTRY_NAME_LEN, c_int))
    count = int(c_filled)
    if (count <= 0) then
      allocate(character(len=1) :: names(0))
      return
    end if

    max_len = max_name_length(c_names, count)
    allocate(character(len=max_len) :: names(count))
    do i = 1, count
      names(i) = name_from_slot(c_names, i)
    end do

    call sort_names(names)
  end function scandir_names

  logical function mkdir_if_needed(path) result(success)
    character(len=*), intent(in) :: path
    character(kind=c_char), allocatable :: c_path(:)

    c_path = to_c_string(path)
    success = (fgof_fs_mkdir_if_needed(c_path, int(o'755', c_int)) /= 0_c_int)
  end function mkdir_if_needed

  logical function unlink_path(path) result(success)
    character(len=*), intent(in) :: path
    character(kind=c_char), allocatable :: c_path(:)

    c_path = to_c_string(path)
    success = (fgof_fs_unlink_path(c_path) /= 0_c_int)
  end function unlink_path

  logical function rmdir_path(path) result(success)
    character(len=*), intent(in) :: path
    character(kind=c_char), allocatable :: c_path(:)

    c_path = to_c_string(path)
    success = (fgof_fs_rmdir_path(c_path) /= 0_c_int)
  end function rmdir_path

  logical function rename_path(source, destination) result(success)
    character(len=*), intent(in) :: source
    character(len=*), intent(in) :: destination
    character(kind=c_char), allocatable :: c_source(:)
    character(kind=c_char), allocatable :: c_destination(:)

    c_source = to_c_string(source)
    c_destination = to_c_string(destination)
    success = (fgof_fs_rename_path(c_source, c_destination) /= 0_c_int)
  end function rename_path

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

  function from_c_string(buf) result(text)
    character(kind=c_char), intent(in) :: buf(:)
    character(len=:), allocatable :: text
    integer :: i
    integer :: n

    n = 0
    do i = 1, size(buf)
      if (buf(i) == c_null_char) exit
      n = n + 1
    end do

    if (n == 0) then
      text = ""
      return
    end if

    allocate(character(len=n) :: text)
    do i = 1, n
      text(i:i) = char(iachar(buf(i)))
    end do
  end function from_c_string

  integer function max_name_length(buf, count) result(max_len)
    character(kind=c_char), intent(in) :: buf(:)
    integer, intent(in) :: count
    integer :: i

    max_len = 1
    do i = 1, count
      max_len = max(max_len, len(name_from_slot(buf, i)))
    end do
  end function max_name_length

  function name_from_slot(buf, index) result(name)
    character(kind=c_char), intent(in) :: buf(:)
    integer, intent(in) :: index
    character(len=:), allocatable :: name
    integer :: offset

    offset = (index - 1) * ENTRY_NAME_LEN
    name = from_c_string(buf(offset + 1:offset + ENTRY_NAME_LEN))
  end function name_from_slot

  subroutine sort_names(names)
    character(len=*), intent(inout) :: names(:)
    character(len=len(names)) :: temp
    integer :: i
    integer :: j

    do i = 1, size(names) - 1
      do j = i + 1, size(names)
        if (trim(names(j)) < trim(names(i))) then
          temp = names(i)
          names(i) = names(j)
          names(j) = temp
        end if
      end do
    end do
  end subroutine sort_names

end module fgof_fs_posix
