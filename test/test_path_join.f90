program test_path_join
  use fgof_path, only : join_path
  implicit none

  if (join_path("alpha", "beta.txt") /= "alpha/beta.txt") error stop "join_path should join plain components"
  if (join_path("alpha/", "beta.txt") /= "alpha/beta.txt") error stop "join_path should avoid duplicate separators from the left side"
  if (join_path("alpha", "/beta.txt") /= "alpha/beta.txt") error stop "join_path should avoid duplicate separators from the right side"
  if (join_path("alpha/", "/beta.txt") /= "alpha/beta.txt") error stop "join_path should collapse duplicate separators from both sides"
  if (join_path("", "beta.txt") /= "beta.txt") error stop "join_path should pass through the right component when the left side is empty"
  if (join_path("alpha", "") /= "alpha") error stop "join_path should pass through the left component when the right side is empty"
  if (join_path("/", "beta.txt") /= "/beta.txt") error stop "join_path should preserve root joins"
end program test_path_join
