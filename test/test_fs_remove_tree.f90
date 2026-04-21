program test_fs_remove_tree
  use fgof_fs, only : exists, remove_tree
  implicit none

  character(len=:), allocatable :: temp_dir
  character(len=:), allocatable :: outside_file
  character(len=128) :: temp_dir_buffer
  integer :: clock_count
  integer :: exit_code

  call system_clock(count=clock_count)
  write(temp_dir_buffer, '("/tmp/fgof-fs-remove-tree-", I0)') clock_count
  temp_dir = trim(temp_dir_buffer)
  outside_file = temp_dir // "-outside.txt"

  call execute_command_line('mkdir -p "' // temp_dir // '/alpha/beta"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create remove-tree directory"

  open(unit=18, file=temp_dir // "/root.txt", status="replace", action="write")
  write(18, '(A)') "root"
  close(18)

  open(unit=19, file=temp_dir // "/alpha/beta/nested.txt", status="replace", action="write")
  write(19, '(A)') "nested"
  close(19)

  open(unit=20, file=outside_file, status="replace", action="write")
  write(20, '(A)') "outside"
  close(20)

  call execute_command_line('ln -s "' // outside_file // '" "' // temp_dir // '/alpha/outside.link"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should create remove-tree symlink"

  if (.not. remove_tree(temp_dir)) error stop "remove_tree should remove nested directory trees"
  if (exists(temp_dir)) error stop "remove_tree should remove the root directory"
  if (.not. exists(outside_file)) error stop "remove_tree should not follow symlink targets outside the tree"

  if (remove_tree(outside_file)) error stop "remove_tree should refuse regular files"
  if (remove_tree(temp_dir)) error stop "remove_tree should fail for missing paths"

  call execute_command_line('rm -f "' // outside_file // '"', exitstat=exit_code)
  if (exit_code /= 0) error stop "should clean remove-tree outside file"
end program test_fs_remove_tree
