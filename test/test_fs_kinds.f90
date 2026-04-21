program test_fs_kinds
  use fgof_fs, only : exists, is_directory, is_file, is_symlink, path_exists
  implicit none

  character(len=:), allocatable :: temp_dir
  character(len=:), allocatable :: temp_file
  character(len=:), allocatable :: temp_link
  character(len=128) :: temp_dir_buffer
  integer :: clock_count
  integer :: exit_code

  if (.not. exists("README.md")) error stop "exists should find tracked files"
  if (.not. path_exists("README.md")) error stop "path_exists should remain available"
  if (exists("fgof-fs-path-that-should-not-exist")) error stop "exists should fail for missing paths"
  if (.not. is_file("README.md")) error stop "README.md should be a regular file"
  if (is_file("src")) error stop "directories should not report as regular files"
  if (.not. is_directory("src")) error stop "src should be a directory"
  if (is_directory("README.md")) error stop "regular files should not report as directories"

  call system_clock(count=clock_count)
  write(temp_dir_buffer, '("/tmp/fgof-fs-kinds-", I0)') clock_count
  temp_dir = trim(temp_dir_buffer)
  temp_file = temp_dir // "/target.txt"
  temp_link = temp_dir // "/target.link"

  call execute_command_line('mkdir -p "' // temp_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create temp test directory"

  open(unit=10, file=temp_file, status="replace", action="write")
  write(10, '(A)') "hello"
  close(10)

  call execute_command_line('ln -s "' // temp_file // '" "' // temp_link // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create temp symlink"

  if (.not. is_symlink(temp_link)) error stop "temp link should report as symlink"
  if (.not. is_file(temp_link)) error stop "symlink to file should stat as file"
  if (is_symlink(temp_file)) error stop "regular file should not report as symlink"

  call execute_command_line('rm -rf "' // temp_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should clean temp test directory"
end program test_fs_kinds
