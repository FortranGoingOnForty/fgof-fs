program test_fs_discovery_edges
  use fgof_fs, only : directory_entry, scandir, walk
  use fgof_path, only : normalize_path
  implicit none

  type(directory_entry), allocatable :: entries(:)
  character(len=:), allocatable :: temp_dir
  character(len=:), allocatable :: plain_file
  character(len=:), allocatable :: target_dir
  character(len=:), allocatable :: target_link
  character(len=128) :: temp_dir_buffer
  integer :: clock_count
  integer :: exit_code

  call system_clock(count=clock_count)
  write(temp_dir_buffer, '("/tmp/fgof-fs-discovery-edges-", I0)') clock_count
  temp_dir = trim(temp_dir_buffer)
  plain_file = temp_dir // "/plain.txt"
  target_dir = temp_dir // "/target"
  target_link = temp_dir // "/target.link"

  call execute_command_line('mkdir -p "' // target_dir // '/nested"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create discovery edge temp directory"

  open(unit=31, file=plain_file, status="replace", action="write")
  write(31, '(A)') "plain"
  close(31)

  open(unit=32, file=target_dir // "/nested/deep.txt", status="replace", action="write")
  write(32, '(A)') "deep"
  close(32)

  call execute_command_line('ln -s "' // target_dir // '" "' // target_link // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create discovery edge symlink"

  entries = scandir(temp_dir // "/missing")
  if (size(entries) /= 0) error stop "scandir should return empty for missing paths"

  entries = scandir(plain_file)
  if (size(entries) /= 0) error stop "scandir should return empty for plain files"

  entries = walk(temp_dir // "/missing")
  if (size(entries) /= 0) error stop "walk should return empty for missing paths"

  entries = walk(plain_file)
  if (size(entries) /= 1) error stop "walk should return a single root entry for files"
  if (entries(1)%path /= normalize_path(plain_file)) error stop "walk file root should preserve the file path"
  if (entries(1)%depth /= 0) error stop "walk file root should have depth 0"
  if (.not. entries(1)%info%is_file) error stop "walk file root should report a file"

  entries = walk(target_link)
  if (size(entries) /= 1) error stop "walk should not recurse into a symlink root"
  if (.not. entries(1)%info%is_symlink) error stop "walk should preserve symlink identity for a symlink root"

  call execute_command_line('rm -rf "' // temp_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should clean discovery edge temp directory"
end program test_fs_discovery_edges
