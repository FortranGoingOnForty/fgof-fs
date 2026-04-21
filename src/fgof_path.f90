module fgof_path
  implicit none
  private

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

end module fgof_path
