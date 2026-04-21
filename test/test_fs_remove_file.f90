program test_fs_remove_file
  use fgof_fs, only : exists, remove_file
  implicit none

  character(len=:), allocatable :: temp_dir
  character(len=:), allocatable :: temp_file
  character(len=:), allocatable :: temp_link
  character(len=128) :: temp_dir_buffer
  integer :: clock_count
  integer :: exit_code

  call system_clock(count=clock_count)
  write(temp_dir_buffer, '("/tmp/fgof-fs-remove-file-", I0)') clock_count
  temp_dir = trim(temp_dir_buffer)
  temp_file = temp_dir // "/plain.txt"
  temp_link = temp_dir // "/plain.link"

  call execute_command_line('mkdir -p "' // temp_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create remove-file temp directory"

  open(unit=17, file=temp_file, status="replace", action="write")
  write(17, '(A)') "hello"
  close(17)

  call execute_command_line('ln -s "' // temp_file // '" "' // temp_link // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create remove-file symlink"

  if (.not. remove_file(temp_link)) error stop "remove_file should unlink symlinks"
  if (exists(temp_link)) error stop "remove_file should remove the symlink path"
  if (.not. exists(temp_file)) error stop "remove_file should not remove the symlink target"

  if (.not. remove_file(temp_file)) error stop "remove_file should unlink regular files"
  if (exists(temp_file)) error stop "remove_file should remove the regular file"

  if (remove_file(temp_dir)) error stop "remove_file should refuse directories"
  if (remove_file(temp_file)) error stop "remove_file should fail for missing paths"

  call execute_command_line('rm -rf "' // temp_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should clean remove-file temp directory"
end program test_fs_remove_file
