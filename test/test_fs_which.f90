program test_fs_which
  use fgof_fs, only : exists, which
  use fgof_path, only : normalize_path
  implicit none

  character(len=:), allocatable :: temp_dir
  character(len=:), allocatable :: script_path
  character(len=:), allocatable :: plain_path
  character(len=:), allocatable :: resolved
  character(len=128) :: temp_dir_buffer
  integer :: clock_count
  integer :: exit_code

  call system_clock(count=clock_count)
  write(temp_dir_buffer, '("/tmp/fgof-fs-which-", I0)') clock_count
  temp_dir = trim(temp_dir_buffer)
  script_path = temp_dir // "/demo-tool"
  plain_path = temp_dir // "/plain.txt"

  call execute_command_line('mkdir -p "' // temp_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create which temp directory"

  call write_text_file(script_path, "#!/bin/sh")
  call append_text_file(script_path, 'printf "demo\n"')
  call execute_command_line('chmod +x "' // script_path // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should mark demo tool executable"

  call write_text_file(plain_path, "plain text")

  resolved = which(script_path)
  if (resolved /= normalize_path(script_path)) error stop "which should return direct executable paths"

  resolved = which("sh")
  if (resolved == "") error stop "which should resolve commands from PATH"
  if (.not. exists(resolved)) error stop "which should resolve to an existing path"

  if (which("fgof-fs-which-missing") /= "") error stop "which should return empty for missing commands"
  if (which(plain_path) /= "") error stop "which should reject non-executable direct paths"
  if (which("") /= "") error stop "which should return empty for empty command names"

  call execute_command_line('rm -rf "' // temp_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should clean which temp directory"

contains

  subroutine write_text_file(path, text)
    character(len=*), intent(in) :: path
    character(len=*), intent(in) :: text
    integer :: unit

    open(newunit=unit, file=path, status="replace", action="write")
    write(unit, '(A)') text
    close(unit)
  end subroutine write_text_file

  subroutine append_text_file(path, text)
    character(len=*), intent(in) :: path
    character(len=*), intent(in) :: text
    integer :: unit

    open(newunit=unit, file=path, status="old", position="append", action="write")
    write(unit, '(A)') text
    close(unit)
  end subroutine append_text_file

end program test_fs_which
