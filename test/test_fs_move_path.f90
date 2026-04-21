program test_fs_move_path
  use fgof_fs, only : exists, is_directory, is_symlink, move_path
  implicit none

  character(len=:), allocatable :: temp_dir
  character(len=:), allocatable :: source_file
  character(len=:), allocatable :: moved_file
  character(len=:), allocatable :: source_dir
  character(len=:), allocatable :: moved_dir
  character(len=:), allocatable :: broken_link
  character(len=:), allocatable :: moved_link
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
  broken_link = temp_dir // "/broken.link"
  moved_link = temp_dir // "/moved.link"

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

  call execute_command_line('ln -s "' // temp_dir // '/missing-target" "' // broken_link // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create broken symlink"

  if (.not. move_path(broken_link, moved_link)) error stop "move_path should rename broken symlinks"
  if (is_symlink(broken_link)) error stop "move_path should remove the old symlink path"
  if (.not. is_symlink(moved_link)) error stop "move_path should preserve broken symlink identity"

  if (move_path(temp_dir // "/missing", temp_dir // "/still-missing")) error stop "move_path should fail for missing paths"

  call execute_command_line('rm -rf "' // temp_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should clean move temp directory"
end program test_fs_move_path
