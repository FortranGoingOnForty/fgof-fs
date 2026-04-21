module fgof_path
  implicit none
  private

  public :: basename
  public :: dirname
  public :: join_path

contains

  function join_path(left, right) result(path)
    character(len=*), intent(in) :: left
    character(len=*), intent(in) :: right
    character(len=:), allocatable :: path
    character(len=:), allocatable :: lhs
    character(len=:), allocatable :: rhs

    lhs = trim(left)
    rhs = trim(right)

    if (len(lhs) == 0) then
      path = rhs
      return
    end if

    if (len(rhs) == 0) then
      path = lhs
      return
    end if

    if (lhs(len(lhs):len(lhs)) == "/") then
      if (rhs(1:1) == "/") then
        path = lhs // rhs(2:)
      else
        path = lhs // rhs
      end if
      return
    end if

    if (rhs(1:1) == "/") then
      path = lhs // rhs
    else
      path = lhs // "/" // rhs
    end if
  end function join_path

  function basename(path_in) result(name)
    character(len=*), intent(in) :: path_in
    character(len=:), allocatable :: name
    character(len=:), allocatable :: path
    integer :: pos

    path = strip_trailing_separators(trim(path_in))
    if (len(path) == 0) then
      name = ""
      return
    end if

    if (path == "/") then
      name = "/"
      return
    end if

    pos = index(path, "/", back=.true.)
    if (pos == 0) then
      name = path
    else
      name = path(pos + 1:)
    end if
  end function basename

  function dirname(path_in) result(parent)
    character(len=*), intent(in) :: path_in
    character(len=:), allocatable :: parent
    character(len=:), allocatable :: path
    integer :: pos

    path = strip_trailing_separators(trim(path_in))
    if (len(path) == 0) then
      parent = "."
      return
    end if

    if (path == "/") then
      parent = "/"
      return
    end if

    pos = index(path, "/", back=.true.)
    if (pos == 0) then
      parent = "."
    else if (pos == 1) then
      parent = "/"
    else
      parent = strip_trailing_separators(path(:pos - 1))
    end if
  end function dirname

  function strip_trailing_separators(path_in) result(path)
    character(len=*), intent(in) :: path_in
    character(len=:), allocatable :: path
    integer :: last

    path = trim(path_in)
    if (len(path) == 0) then
      return
    end if

    last = len(path)
    do while (last > 1 .and. path(last:last) == "/")
      last = last - 1
    end do

    if (last == 1 .and. path(1:1) == "/") then
      path = "/"
    else
      path = path(:last)
    end if
  end function strip_trailing_separators

end module fgof_path
