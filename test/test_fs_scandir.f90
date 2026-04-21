program test_fs_scandir
  use fgof_fs, only : directory_entry, scandir
  implicit none

  type(directory_entry), allocatable :: entries(:)
  character(len=:), allocatable :: temp_dir
  character(len=128) :: temp_dir_buffer
  integer :: clock_count
  integer :: exit_code
  integer :: idx

  call system_clock(count=clock_count)
  write(temp_dir_buffer, '("/tmp/fgof-fs-scandir-", I0)') clock_count
  temp_dir = trim(temp_dir_buffer)

  call execute_command_line('mkdir -p "' // temp_dir // '/child dir"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create scandir child directory"

  open(unit=12, file=temp_dir // "/plain.txt", status="replace", action="write")
  write(12, '(A)') "hello"
  close(12)

  open(unit=13, file=temp_dir // "/.hidden", status="replace", action="write")
  write(13, '(A)') "hidden"
  close(13)

  call execute_command_line('ln -s "' // temp_dir // '/plain.txt" "' // temp_dir // '/plain.link"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create scandir symlink"

  entries = scandir(temp_dir)
  if (size(entries) /= 4) error stop "scandir should return direct children"

  idx = find_entry(entries, ".hidden")
  if (idx == 0) error stop "scandir should include hidden files"
  if (.not. entries(idx)%info%is_file) error stop "hidden file should report as file"

  idx = find_entry(entries, "child dir")
  if (idx == 0) error stop "scandir should include child directory"
  if (.not. entries(idx)%info%is_directory) error stop "child dir should report as directory"
  if (entries(idx)%depth /= 1) error stop "direct scandir entries should use depth 1"

  idx = find_entry(entries, "plain.link")
  if (idx == 0) error stop "scandir should include symlinks"
  if (.not. entries(idx)%info%is_symlink) error stop "symlink should preserve link identity in scandir"

  if (trim(entries(1)%name) /= ".hidden") error stop "scandir should sort entries lexically"

  call execute_command_line('rm -rf "' // temp_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should clean scandir temp directory"

contains

  integer function find_entry(entries, name) result(idx)
    type(directory_entry), intent(in) :: entries(:)
    character(len=*), intent(in) :: name
    integer :: i

    idx = 0
    do i = 1, size(entries)
      if (trim(entries(i)%name) == trim(name)) then
        idx = i
        return
      end if
    end do
  end function find_entry

end program test_fs_scandir
