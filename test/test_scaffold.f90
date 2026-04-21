program test_scaffold
  use fgof_fs, only : path_exists
  use fgof_path, only : join_path
  implicit none

  if (join_path("alpha", "beta") /= "alpha/beta") error stop "join_path should join with slash"
  if (join_path("alpha/", "beta") /= "alpha/beta") error stop "join_path should avoid duplicate slash"
  if (.not. path_exists("README.md")) error stop "path_exists should see tracked files in the repo root"
end program test_scaffold
