program test_fs_walk
  use fgof_fs, only : directory_entry, walk
  use fgof_path, only : normalize_path
  implicit none

  type(directory_entry), allocatable :: entries(:)
  character(len=:), allocatable :: temp_dir
  character(len=128) :: temp_dir_buffer
  integer :: clock_count
  integer :: exit_code
  integer :: idx

  call system_clock(count=clock_count)
  write(temp_dir_buffer, '("/tmp/fgof-fs-walk-", I0)') clock_count
  temp_dir = trim(temp_dir_buffer)

  call execute_command_line('mkdir -p "' // temp_dir // '/alpha dir"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create walk child directory"

  open(unit=14, file=temp_dir // "/plain.txt", status="replace", action="write")
  write(14, '(A)') "hello"
  close(14)

  open(unit=15, file=temp_dir // "/.hidden", status="replace", action="write")
  write(15, '(A)') "hidden"
  close(15)

  open(unit=16, file=temp_dir // "/alpha dir/nested.txt", status="replace", action="write")
  write(16, '(A)') "nested"
  close(16)

  call execute_command_line('ln -s "' // temp_dir // '/plain.txt" "' // temp_dir // '/plain.link"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create walk symlink"

  entries = walk(temp_dir)
  if (size(entries) /= 6) error stop "walk should include root and nested descendants"

  if (entries(1)%path /= normalize_path(temp_dir)) error stop "walk should start with the root path"
  if (entries(1)%depth /= 0) error stop "walk root should have depth 0"
  if (.not. entries(1)%info%is_directory) error stop "walk root should be a directory"

  idx = find_path(entries, normalize_path(temp_dir // "/alpha dir/nested.txt"))
  if (idx == 0) error stop "walk should include nested files"
  if (entries(idx)%depth /= 2) error stop "nested file should have depth 2"

  idx = find_path(entries, normalize_path(temp_dir // "/plain.link"))
  if (idx == 0) error stop "walk should include symlink entries"
  if (.not. entries(idx)%info%is_symlink) error stop "walk should preserve symlink identity"

  call execute_command_line('rm -rf "' // temp_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should clean walk temp directory"

contains

  integer function find_path(entries, path) result(idx)
    type(directory_entry), intent(in) :: entries(:)
    character(len=*), intent(in) :: path
    integer :: i

    idx = 0
    do i = 1, size(entries)
      if (trim(entries(i)%path) == trim(path)) then
        idx = i
        return
      end if
    end do
  end function find_path

end program test_fs_walk
