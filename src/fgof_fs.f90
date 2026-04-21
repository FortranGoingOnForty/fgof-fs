module fgof_fs
  use fgof_fs_posix, only : S_IFDIR, S_IFLNK, S_IFMT, S_IFREG, lstat_mode, stat_mode
  implicit none
  private

  public :: exists
  public :: is_directory
  public :: is_file
  public :: is_symlink
  public :: path_exists

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

end module fgof_fs
