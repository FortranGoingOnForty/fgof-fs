module fgof_path
  implicit none
  private

  public :: basename
  public :: dirname
  public :: join_path
  public :: normalize_path

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

  function normalize_path(path_in) result(path_out)
    character(len=*), intent(in) :: path_in
    character(len=:), allocatable :: path_out
    character(len=:), allocatable :: path
    character(len=:), allocatable :: component
    character(len=:), allocatable :: stack(:)
    logical :: is_absolute
    integer :: i
    integer :: start_idx
    integer :: end_idx
    integer :: top
    integer :: total_len

    path = trim(path_in)
    if (len(path) == 0) then
      path_out = "."
      return
    end if

    is_absolute = (path(1:1) == "/")
    allocate(character(len=max(1, len(path))) :: stack(max(1, len(path))))
    stack = ""
    top = 0

    i = 1
    do while (i <= len(path))
      do while (i <= len(path) .and. path(i:i) == "/")
        i = i + 1
      end do
      if (i > len(path)) exit

      start_idx = i
      do while (i <= len(path) .and. path(i:i) /= "/")
        i = i + 1
      end do
      end_idx = i - 1
      component = path(start_idx:end_idx)

      select case (component)
      case (".")
        cycle
      case ("..")
        if (is_absolute) then
          if (top > 0) top = top - 1
        else
          if (top > 0 .and. stack(top) /= "..") then
            top = top - 1
          else
            top = top + 1
            stack(top) = component
          end if
        end if
      case default
        top = top + 1
        stack(top) = component
      end select
    end do

    if (top == 0) then
      if (is_absolute) then
        path_out = "/"
      else
        path_out = "."
      end if
      return
    end if

    total_len = top - 1
    do i = 1, top
      total_len = total_len + len_trim(stack(i))
    end do
    if (is_absolute) total_len = total_len + 1

    allocate(character(len=total_len) :: path_out)
    if (is_absolute) then
      path_out = "/" // trim(stack(1))
    else
      path_out = trim(stack(1))
    end if

    do i = 2, top
      path_out = path_out // "/" // trim(stack(i))
    end do
  end function normalize_path

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
