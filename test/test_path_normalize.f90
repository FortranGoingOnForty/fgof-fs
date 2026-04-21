program test_path_normalize
  use fgof_path, only : normalize_path
  implicit none

  if (normalize_path("") /= ".") error stop "empty path should normalize to current directory"
  if (normalize_path("alpha//beta/./gamma") /= "alpha/beta/gamma") error stop "normalize_path should collapse separators and dots"
  if (normalize_path("./alpha/../beta") /= "beta") error stop "normalize_path should resolve relative parent segments"
  if (normalize_path("/alpha/../beta") /= "/beta") error stop "normalize_path should resolve absolute parent segments"
  if (normalize_path("alpha/../../beta") /= "../beta") error stop "normalize_path should preserve leading relative parent escapes"
  if (normalize_path("/../alpha") /= "/alpha") error stop "normalize_path should not climb above root"
  if (normalize_path("/") /= "/") error stop "normalize_path should preserve root"
end program test_path_normalize
