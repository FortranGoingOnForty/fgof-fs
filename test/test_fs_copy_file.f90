program test_fs_copy_file
  use fgof_fs, only : copy_file, exists, is_directory
  implicit none

  character(len=:), allocatable :: temp_dir
  character(len=:), allocatable :: source_file
  character(len=:), allocatable :: copied_file
  character(len=:), allocatable :: overwrite_file
  character(len=:), allocatable :: source_dir
  character(len=:), allocatable :: source_link
  character(len=:), allocatable :: destination_link
  character(len=128) :: temp_dir_buffer
  integer :: clock_count
  integer :: exit_code

  call system_clock(count=clock_count)
  write(temp_dir_buffer, '("/tmp/fgof-fs-copy-", I0)') clock_count
  temp_dir = trim(temp_dir_buffer)
  source_file = temp_dir // "/plain.txt"
  copied_file = temp_dir // "/copied.txt"
  overwrite_file = temp_dir // "/overwrite.txt"
  source_dir = temp_dir // "/alpha"
  source_link = temp_dir // "/source-link"
  destination_link = temp_dir // "/destination-link"

  call execute_command_line('mkdir -p "' // source_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create copy temp directory"

  call write_text_file(source_file, "hello copy")
  call write_text_file(overwrite_file, "old text")

  call execute_command_line('ln -s "' // source_file // '" "' // source_link // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create source symlink"

  call execute_command_line('ln -s "' // overwrite_file // '" "' // destination_link // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create destination symlink"

  if (.not. copy_file(source_file, copied_file)) error stop "copy_file should copy regular files"
  if (.not. exists(copied_file)) error stop "copy_file should create the destination file"
  if (read_text_file(copied_file) /= "hello copy") error stop "copy_file should preserve file content"

  if (.not. copy_file(source_file, overwrite_file)) error stop "copy_file should overwrite plain files"
  if (read_text_file(overwrite_file) /= "hello copy") error stop "copy_file should replace destination content"

  if (copy_file(temp_dir // "/missing.txt", temp_dir // "/still-missing.txt")) error stop "copy_file should fail for missing files"
  if (copy_file(source_dir, temp_dir // "/from-dir.txt")) error stop "copy_file should fail for directories"
  if (copy_file(source_file, source_dir)) error stop "copy_file should fail when the destination is a directory"
  if (copy_file(source_link, temp_dir // "/from-link.txt")) error stop "copy_file should reject source symlinks"
  if (copy_file(source_file, destination_link)) error stop "copy_file should reject destination symlinks"
  if (.not. is_directory(source_dir)) error stop "source directory should still exist"

  call execute_command_line('rm -rf "' // temp_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should clean copy temp directory"

contains

  subroutine write_text_file(path, text)
    character(len=*), intent(in) :: path
    character(len=*), intent(in) :: text
    integer :: unit

    open(newunit=unit, file=path, status="replace", action="write")
    write(unit, '(A)') text
    close(unit)
  end subroutine write_text_file

  function read_text_file(path) result(text)
    character(len=*), intent(in) :: path
    character(len=:), allocatable :: text
    character(len=256) :: buffer
    integer :: unit

    open(newunit=unit, file=path, status="old", action="read")
    read(unit, '(A)') buffer
    close(unit)

    text = trim(buffer)
  end function read_text_file

end program test_fs_copy_file
