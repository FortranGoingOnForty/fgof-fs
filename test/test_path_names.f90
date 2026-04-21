program test_path_names
  use fgof_path, only : basename, dirname
  implicit none

  if (basename("alpha/beta.txt") /= "beta.txt") error stop "basename should return final path component"
  if (basename("alpha/beta/") /= "beta") error stop "basename should ignore trailing separators"
  if (basename("/") /= "/") error stop "basename should preserve root"
  if (basename("alpha") /= "alpha") error stop "basename should pass through simple names"

  if (dirname("alpha/beta.txt") /= "alpha") error stop "dirname should return parent path"
  if (dirname("/alpha/beta/") /= "/alpha") error stop "dirname should ignore trailing separators"
  if (dirname("alpha") /= ".") error stop "dirname should map leaf names to current directory"
  if (dirname("/") /= "/") error stop "dirname should preserve root"
end program test_path_names
