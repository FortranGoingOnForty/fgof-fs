program test_fs_current_dir
  use fgof_fs, only : current_dir, exists, is_directory
  implicit none

  character(len=:), allocatable :: cwd

  cwd = current_dir()
  if (len(cwd) == 0) error stop "current_dir should return a path"
  if (cwd(1:1) /= "/") error stop "current_dir should return an absolute path on POSIX"
  if (.not. exists(cwd)) error stop "current_dir should return an existing path"
  if (.not. is_directory(cwd)) error stop "current_dir should return a directory path"
end program test_fs_current_dir
