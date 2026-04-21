module fgof_fs
  use fgof_fs_posix, only : S_IFDIR, S_IFLNK, S_IFMT, S_IFREG, current_dir, lstat_mode, lstat_size, stat_mode, stat_size
  use fgof_fs_types, only : path_info
  use iso_fortran_env, only : int64
  implicit none
  private

  public :: exists
  public :: is_directory
  public :: is_file
  public :: is_symlink
  public :: path_exists
  public :: path_info
  public :: current_dir
  public :: lstat
  public :: stat

contains

  logical function path_exists(path) result(found)
    character(len=*), intent(in) :: path

    found = exists(path)
  end function path_exists

  logical function exists(path) result(found)
    character(len=*), intent(in) :: path

    found = (stat_mode(path) >= 0)
  end function exists

  logical function is_file(path) result(found)
    character(len=*), intent(in) :: path
    integer :: mode

    mode = stat_mode(path)
    found = (mode >= 0 .and. iand(mode, S_IFMT) == S_IFREG)
  end function is_file

  logical function is_directory(path) result(found)
    character(len=*), intent(in) :: path
    integer :: mode

    mode = stat_mode(path)
    found = (mode >= 0 .and. iand(mode, S_IFMT) == S_IFDIR)
  end function is_directory

  logical function is_symlink(path) result(found)
    character(len=*), intent(in) :: path
    integer :: mode

    mode = lstat_mode(path)
    found = (mode >= 0 .and. iand(mode, S_IFMT) == S_IFLNK)
  end function is_symlink

  function stat(path) result(info)
    character(len=*), intent(in) :: path
    type(path_info) :: info
    integer :: mode
    integer(int64) :: size_bytes

    mode = stat_mode(path)
    if (mode < 0) return

    size_bytes = stat_size(path)
    info = path_info( &
      exists=.true., &
      is_file=(iand(mode, S_IFMT) == S_IFREG), &
      is_directory=(iand(mode, S_IFMT) == S_IFDIR), &
      is_symlink=.false., &
      mode=mode, &
      size=size_bytes &
    )
  end function stat

  function lstat(path) result(info)
    character(len=*), intent(in) :: path
    type(path_info) :: info
    integer :: mode
    integer(int64) :: size_bytes

    mode = lstat_mode(path)
    if (mode < 0) return

    size_bytes = lstat_size(path)
    info = path_info( &
      exists=.true., &
      is_file=(iand(mode, S_IFMT) == S_IFREG), &
      is_directory=(iand(mode, S_IFMT) == S_IFDIR), &
      is_symlink=(iand(mode, S_IFMT) == S_IFLNK), &
      mode=mode, &
      size=size_bytes &
    )
  end function lstat

end module fgof_fs
