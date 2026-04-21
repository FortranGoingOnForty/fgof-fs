program test_fs_stat
  use fgof_fs, only : lstat, path_info, stat
  implicit none

  type(path_info) :: info
  type(path_info) :: link_info
  character(len=:), allocatable :: temp_dir
  character(len=:), allocatable :: temp_file
  character(len=:), allocatable :: temp_link
  character(len=128) :: temp_dir_buffer
  integer :: clock_count
  integer :: exit_code

  info = stat("README.md")
  if (.not. info%exists) error stop "stat should mark tracked file as existing"
  if (.not. info%is_file) error stop "stat should mark README.md as a regular file"
  if (info%is_directory) error stop "stat should not mark README.md as a directory"
  if (info%is_symlink) error stop "stat should not mark README.md as a symlink"
  if (info%size <= 0) error stop "stat should report a positive file size"

  info = stat("src")
  if (.not. info%exists) error stop "stat should mark src as existing"
  if (.not. info%is_directory) error stop "stat should mark src as a directory"
  if (info%is_file) error stop "stat should not mark src as a regular file"

  info = stat("fgof-fs-path-that-should-not-exist")
  if (info%exists) error stop "stat should report missing paths as absent"
  if (info%size /= -1) error stop "missing path size should stay at default value"

  call system_clock(count=clock_count)
  write(temp_dir_buffer, '("/tmp/fgof-fs-stat-", I0)') clock_count
  temp_dir = trim(temp_dir_buffer)
  temp_file = temp_dir // "/target.txt"
  temp_link = temp_dir // "/target.link"

  call execute_command_line('mkdir -p "' // temp_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create temp stat directory"

  open(unit=11, file=temp_file, status="replace", action="write")
  write(11, '(A)') "hello"
  close(11)

  call execute_command_line('ln -s "' // temp_file // '" "' // temp_link // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create temp stat symlink"

  info = stat(temp_link)
  if (.not. info%exists) error stop "stat should follow symlink target"
  if (.not. info%is_file) error stop "stat should report symlink-to-file as a file"
  if (info%is_symlink) error stop "stat should not report followed symlink as symlink"

  link_info = lstat(temp_link)
  if (.not. link_info%exists) error stop "lstat should mark symlink as existing"
  if (.not. link_info%is_symlink) error stop "lstat should preserve symlink identity"
  if (link_info%size <= 0) error stop "lstat should report symlink path length"

  call execute_command_line('rm -rf "' // temp_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should clean temp stat directory"
end program test_fs_stat
