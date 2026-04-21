program test_fs_move_path
  use fgof_fs, only : exists, is_directory, move_path
  implicit none

  character(len=:), allocatable :: temp_dir
  character(len=:), allocatable :: source_file
  character(len=:), allocatable :: moved_file
  character(len=:), allocatable :: source_dir
  character(len=:), allocatable :: moved_dir
  character(len=128) :: temp_dir_buffer
  integer :: clock_count
  integer :: exit_code

  call system_clock(count=clock_count)
  write(temp_dir_buffer, '("/tmp/fgof-fs-move-", I0)') clock_count
  temp_dir = trim(temp_dir_buffer)
  source_file = temp_dir // "/plain.txt"
  moved_file = temp_dir // "/moved.txt"
  source_dir = temp_dir // "/alpha"
  moved_dir = temp_dir // "/beta"

  call execute_command_line('mkdir -p "' // source_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create move temp directory"

  open(unit=21, file=source_file, status="replace", action="write")
  write(21, '(A)') "hello"
  close(21)

  if (.not. move_path(source_file, moved_file)) error stop "move_path should rename files"
  if (exists(source_file)) error stop "move_path should remove the old file path"
  if (.not. exists(moved_file)) error stop "move_path should create the new file path"

  if (.not. move_path(source_dir, moved_dir)) error stop "move_path should rename directories"
  if (exists(source_dir)) error stop "move_path should remove the old directory path"
  if (.not. is_directory(moved_dir)) error stop "move_path should move directories"

  if (move_path(temp_dir // "/missing", temp_dir // "/still-missing")) error stop "move_path should fail for missing paths"

  call execute_command_line('rm -rf "' // temp_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should clean move temp directory"
end program test_fs_move_path
