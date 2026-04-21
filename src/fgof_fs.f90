module fgof_fs
  implicit none
  private

  public :: path_exists

contains

  logical function path_exists(path) result(exists)
    character(len=*), intent(in) :: path

    inquire(file=trim(path), exist=exists)
  end function path_exists

end module fgof_fs
