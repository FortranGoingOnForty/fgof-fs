program test_fs_mutation_edges
  use fgof_fs, only : copy_file, exists, move_path, remove_tree
  implicit none

  character(len=:), allocatable :: temp_dir
  character(len=:), allocatable :: source_file
  character(len=:), allocatable :: destination_file
  character(len=:), allocatable :: missing_parent_file
  character(len=:), allocatable :: tree_dir
  character(len=:), allocatable :: target_file
  character(len=:), allocatable :: target_link
  character(len=128) :: temp_dir_buffer
  integer :: clock_count
  integer :: exit_code

  call system_clock(count=clock_count)
  write(temp_dir_buffer, '("/tmp/fgof-fs-mutation-edges-", I0)') clock_count
  temp_dir = trim(temp_dir_buffer)
  source_file = temp_dir // "/source.txt"
  destination_file = temp_dir // "/destination.txt"
  missing_parent_file = temp_dir // "/missing/out.txt"
  tree_dir = temp_dir // "/tree"
  target_file = temp_dir // "/target.txt"
  target_link = tree_dir // "/target.link"

  call execute_command_line('mkdir -p "' // tree_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create mutation edge temp directory"

  call write_text_file(source_file, "fresh")
  call write_text_file(destination_file, "stale")

  if (.not. move_path(source_file, destination_file)) error stop "move_path should overwrite plain destination files"
  if (exists(source_file)) error stop "move_path overwrite should remove the source path"
  if (read_text_file(destination_file) /= "fresh") error stop "move_path overwrite should replace destination content"

  call write_text_file(source_file, "copy source")
  if (copy_file(source_file, missing_parent_file)) error stop "copy_file should fail when parent directories are missing"
  if (.not. exists(source_file)) error stop "copy_file failure should leave the source file in place"

  call write_text_file(target_file, "keep me")
  call execute_command_line('ln -s "' // target_file // '" "' // target_link // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create mutation edge symlink"

  if (.not. remove_tree(tree_dir)) error stop "remove_tree should remove directories that contain symlinks"
  if (exists(tree_dir)) error stop "remove_tree should remove the tree directory"
  if (.not. exists(target_file)) error stop "remove_tree should not remove symlink targets outside the tree"

  call execute_command_line('rm -rf "' // temp_dir // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should clean mutation edge temp directory"

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

end program test_fs_mutation_edges
