program test_fs_literal_names
  use fgof_fs, only : directory_entry, exists, scandir, walk, which
  use fgof_path, only : basename, dirname, join_path, normalize_path
  implicit none

  type(directory_entry), allocatable :: entries(:)
  character(len=:), allocatable :: temp_dir
  character(len=:), allocatable :: trailing_file
  character(len=:), allocatable :: trailing_dir
  character(len=:), allocatable :: nested_file
  character(len=:), allocatable :: script_path
  character(len=:), allocatable :: resolved
  character(len=128) :: temp_dir_buffer
  integer :: clock_count
  integer :: exit_code
  integer :: idx

  call system_clock(count=clock_count)
  write(temp_dir_buffer, '("/tmp/fgof-fs-literal-", I0)') clock_count
  temp_dir = trim(temp_dir_buffer)
  trailing_file = temp_dir // "/plain trail "
  trailing_dir = temp_dir // "/dir trail "
  nested_file = trailing_dir // "/child trail "
  script_path = temp_dir // "/tool trail "

  call execute_command_line('mkdir -p "' // trailing_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create trailing-space directory"

  call execute_command_line('printf "hello\n" > "' // trailing_file // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create trailing-space file"

  call execute_command_line('printf "nested\n" > "' // nested_file // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create nested trailing-space file"

  call execute_command_line('printf "#!/bin/sh\nexit 0\n" > "' // script_path // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create trailing-space script"

  call execute_command_line('chmod +x "' // script_path // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should make trailing-space script executable"

  if (join_path(temp_dir, "plain trail ") /= trailing_file) error stop "join_path should preserve trailing spaces"
  if (basename(trailing_file) /= "plain trail ") error stop "basename should preserve trailing spaces"
  if (dirname(trailing_file) /= temp_dir) error stop "dirname should preserve parent paths exactly"
  if (normalize_path(temp_dir // "/./plain trail ") /= trailing_file) error stop "normalize_path should preserve trailing-space components"
  if (.not. exists(trailing_file)) error stop "exists should find trailing-space files"

  entries = scandir(temp_dir)
  idx = find_entry_name(entries, "plain trail ")
  if (idx == 0) error stop "scandir should preserve trailing-space names"
  if (entries(idx)%name /= "plain trail ") error stop "scandir names should remain exact"
  if (entries(idx)%path /= trailing_file) error stop "scandir paths should remain exact"

  entries = walk(temp_dir)
  idx = find_entry_path(entries, nested_file)
  if (idx == 0) error stop "walk should preserve nested trailing-space paths"
  if (entries(idx)%path /= nested_file) error stop "walk paths should remain exact"

  resolved = which(script_path)
  if (resolved /= normalize_path(script_path)) error stop "which should preserve direct paths with trailing spaces"

  call execute_command_line('rm -rf "' // temp_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should clean trailing-space temp directory"

contains

  integer function find_entry_name(entries, name) result(idx)
    type(directory_entry), intent(in) :: entries(:)
    character(len=*), intent(in) :: name
    integer :: i

    idx = 0
    do i = 1, size(entries)
      if (entries(i)%name == name) then
        idx = i
        return
      end if
    end do
  end function find_entry_name

  integer function find_entry_path(entries, path) result(idx)
    type(directory_entry), intent(in) :: entries(:)
    character(len=*), intent(in) :: path
    integer :: i

    idx = 0
    do i = 1, size(entries)
      if (entries(i)%path == path) then
        idx = i
        return
      end if
    end do
  end function find_entry_path

end program test_fs_literal_names
