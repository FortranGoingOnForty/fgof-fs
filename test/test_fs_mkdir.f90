program test_fs_mkdir
  use fgof_fs, only : exists, is_directory, mkdir_p
  implicit none

  character(len=:), allocatable :: temp_dir
  character(len=:), allocatable :: nested_dir
  character(len=128) :: temp_dir_buffer
  integer :: clock_count
  integer :: exit_code

  call system_clock(count=clock_count)
  write(temp_dir_buffer, '("/tmp/fgof-fs-mkdir-", I0)') clock_count
  temp_dir = trim(temp_dir_buffer)
  nested_dir = temp_dir // "/alpha dir/beta/gamma"

  if (.not. mkdir_p(nested_dir)) error stop "mkdir_p should create nested directories"
  if (.not. is_directory(nested_dir)) error stop "mkdir_p should leave the deepest directory on disk"
  if (.not. mkdir_p(nested_dir)) error stop "mkdir_p should be idempotent for existing directories"
  if (.not. exists(temp_dir // "/alpha dir")) error stop "mkdir_p should create intermediate directories"

  call execute_command_line('touch "' // temp_dir // '/plain.txt"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create file for mkdir_p conflict test"
  if (mkdir_p(temp_dir // "/plain.txt/child")) error stop "mkdir_p should fail when a path segment is a file"

  call execute_command_line('rm -rf "' // temp_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should clean mkdir temp directory"
end program test_fs_mkdir
