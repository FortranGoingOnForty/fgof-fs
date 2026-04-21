module fgof_fs
  use fgof_fs_posix, only : S_IFDIR, S_IFLNK, S_IFMT, S_IFREG, copy_file_path, current_dir, fs_name, is_executable_path, lstat_mode, lstat_size, mkdir_if_needed, rename_path, rmdir_path, scandir_names, stat_mode, stat_size, unlink_path
  use fgof_fs_types, only : directory_entry, path_info
  use iso_fortran_env, only : int64
  use fgof_path, only : basename, join_path, normalize_path
  implicit none
  private

  public :: exists
  public :: directory_entry
  public :: copy_file
  public :: is_directory
  public :: is_file
  public :: is_symlink
  public :: remove_file
  public :: remove_tree
  public :: move_path
  public :: path_exists
  public :: path_info
  public :: current_dir
  public :: lstat
  public :: mkdir_p
  public :: scandir
  public :: stat
  public :: walk
  public :: which

contains

  logical function path_exists(path) result(found)
    character(len=*), intent(in) :: path

    found = exists(path)
  end function path_exists

  logical function exists(path) result(found)
    character(len=*), intent(in) :: path

    found = (stat_mode(path) >= 0)
  end function exists

  logical function is_file(path) result(found)
    character(len=*), intent(in) :: path
    integer :: mode

    mode = stat_mode(path)
    found = (mode >= 0 .and. iand(mode, S_IFMT) == S_IFREG)
  end function is_file

  logical function is_directory(path) result(found)
    character(len=*), intent(in) :: path
    integer :: mode

    mode = stat_mode(path)
    found = (mode >= 0 .and. iand(mode, S_IFMT) == S_IFDIR)
  end function is_directory

  logical function is_symlink(path) result(found)
    character(len=*), intent(in) :: path
    integer :: mode

    mode = lstat_mode(path)
    found = (mode >= 0 .and. iand(mode, S_IFMT) == S_IFLNK)
  end function is_symlink

  function stat(path) result(info)
    character(len=*), intent(in) :: path
    type(path_info) :: info
    integer :: mode
    integer(int64) :: size_bytes

    mode = stat_mode(path)
    if (mode < 0) return

    size_bytes = stat_size(path)
    info = path_info( &
      exists=.true., &
      is_file=(iand(mode, S_IFMT) == S_IFREG), &
      is_directory=(iand(mode, S_IFMT) == S_IFDIR), &
      is_symlink=.false., &
      mode=mode, &
      size=size_bytes &
    )
  end function stat

  function lstat(path) result(info)
    character(len=*), intent(in) :: path
    type(path_info) :: info
    integer :: mode
    integer(int64) :: size_bytes

    mode = lstat_mode(path)
    if (mode < 0) return

    size_bytes = lstat_size(path)
    info = path_info( &
      exists=.true., &
      is_file=(iand(mode, S_IFMT) == S_IFREG), &
      is_directory=(iand(mode, S_IFMT) == S_IFDIR), &
      is_symlink=(iand(mode, S_IFMT) == S_IFLNK), &
      mode=mode, &
      size=size_bytes &
    )
  end function lstat

  function scandir(path) result(entries)
    character(len=*), intent(in) :: path
    type(directory_entry), allocatable :: entries(:)
    type(fs_name), allocatable :: names(:)
    integer :: i

    if (.not. is_directory(path)) then
      allocate(entries(0))
      return
    end if

    names = scandir_names(path)
    allocate(entries(size(names)))
    do i = 1, size(names)
      entries(i) = make_directory_entry(join_path(path, names(i)%text), 1)
    end do
  end function scandir

  function walk(path) result(entries)
    character(len=*), intent(in) :: path
    type(directory_entry), allocatable :: entries(:)
    integer :: total
    integer :: next_index

    total = count_walk_entries(path)
    allocate(entries(total))
    if (total == 0) return

    next_index = 1
    call collect_walk_entries(path, 0, entries, next_index)
  end function walk

  logical function mkdir_p(path) result(success)
    character(len=*), intent(in) :: path
    character(len=:), allocatable :: normalized
    character(len=:), allocatable :: partial
    character(len=:), allocatable :: component
    logical :: is_absolute
    integer :: i
    integer :: start_idx
    integer :: end_idx

    normalized = normalize_path(path)
    if (normalized == ".") then
      success = is_directory(".")
      return
    end if

    if (normalized == "/") then
      success = is_directory("/")
      return
    end if

    is_absolute = (normalized(1:1) == "/")
    if (is_absolute) then
      partial = "/"
      i = 2
    else
      partial = ""
      i = 1
    end if

    success = .true.
    do while (i <= len(normalized))
      start_idx = i
      do while (i <= len(normalized) .and. normalized(i:i) /= "/")
        i = i + 1
      end do
      end_idx = i - 1
      component = normalized(start_idx:end_idx)
      partial = join_path(partial, component)

      if (.not. mkdir_if_needed(partial)) then
        success = .false.
        return
      end if

      i = i + 1
    end do
  end function mkdir_p

  logical function remove_file(path) result(success)
    character(len=*), intent(in) :: path
    type(path_info) :: info

    info = lstat(path)
    if (.not. info%exists) then
      success = .false.
      return
    end if

    if (info%is_directory .and. .not. info%is_symlink) then
      success = .false.
      return
    end if

    success = unlink_path(path)
  end function remove_file

  recursive logical function remove_tree(path) result(success)
    character(len=*), intent(in) :: path
    type(path_info) :: info
    type(directory_entry), allocatable :: entries(:)
    integer :: i

    info = lstat(path)
    if (.not. info%exists) then
      success = .false.
      return
    end if

    if (.not. info%is_directory .or. info%is_symlink) then
      success = .false.
      return
    end if

    entries = scandir(path)
    do i = 1, size(entries)
      if (entries(i)%info%is_directory .and. .not. entries(i)%info%is_symlink) then
        if (.not. remove_tree(entries(i)%path)) then
          success = .false.
          return
        end if
      else
        if (.not. remove_file(entries(i)%path)) then
          success = .false.
          return
        end if
      end if
    end do

    success = rmdir_path(path)
  end function remove_tree

  logical function move_path(source, destination) result(success)
    character(len=*), intent(in) :: source
    character(len=*), intent(in) :: destination

    if (.not. exists(source)) then
      success = .false.
      return
    end if

    success = rename_path(source, destination)
  end function move_path

  logical function copy_file(source, destination) result(success)
    character(len=*), intent(in) :: source
    character(len=*), intent(in) :: destination
    type(path_info) :: source_info
    type(path_info) :: destination_info

    source_info = lstat(source)
    if (.not. source_info%exists) then
      success = .false.
      return
    end if

    if (.not. source_info%is_file .or. source_info%is_symlink) then
      success = .false.
      return
    end if

    destination_info = lstat(destination)
    if (destination_info%exists) then
      if (.not. destination_info%is_file .or. destination_info%is_symlink) then
        success = .false.
        return
      end if
    end if

    success = copy_file_path(source, destination)
  end function copy_file

  function which(name) result(path)
    character(len=*), intent(in) :: name
    character(len=:), allocatable :: path
    character(len=:), allocatable :: command
    character(len=:), allocatable :: search_path
    character(len=:), allocatable :: candidate
    character(len=:), allocatable :: directory
    integer :: path_len
    integer :: status
    integer :: start_idx
    integer :: end_idx

    command = name
    if (len(command) == 0) then
      path = ""
      return
    end if

    if (index(command, "/") > 0) then
      if (is_file(command) .and. is_executable_path(command)) then
        path = normalize_path(command)
      else
        path = ""
      end if
      return
    end if

    call get_environment_variable("PATH", length=path_len, status=status)
    if (status /= 0 .or. path_len <= 0) then
      path = ""
      return
    end if

    allocate(character(len=path_len) :: search_path)
    call get_environment_variable("PATH", value=search_path, status=status)
    if (status /= 0) then
      path = ""
      return
    end if

    start_idx = 1
    do while (start_idx <= len(search_path) + 1)
      if (start_idx > len(search_path)) then
        directory = ""
        end_idx = 0
      else
        end_idx = index(search_path(start_idx:), ":")
        if (end_idx == 0) then
          directory = search_path(start_idx:)
        else if (end_idx == 1) then
          directory = ""
        else
          directory = search_path(start_idx:start_idx + end_idx - 2)
        end if
      end if

      if (len(directory) == 0) then
        candidate = join_path(".", command)
      else
        candidate = join_path(directory, command)
      end if

      if (is_file(candidate) .and. is_executable_path(candidate)) then
        path = normalize_path(candidate)
        return
      end if

      if (start_idx > len(search_path) .or. end_idx == 0) exit
      start_idx = start_idx + end_idx
    end do

    path = ""
  end function which

  function make_directory_entry(path, depth) result(entry)
    character(len=*), intent(in) :: path
    integer, intent(in) :: depth
    type(directory_entry) :: entry

    entry%path = normalize_path(path)
    entry%name = basename(entry%path)
    entry%depth = depth
    entry%info = lstat(entry%path)
  end function make_directory_entry

  recursive integer function count_walk_entries(path) result(total)
    character(len=*), intent(in) :: path
    type(directory_entry), allocatable :: children(:)
    type(path_info) :: info
    integer :: i

    info = lstat(path)
    if (.not. info%exists) then
      total = 0
      return
    end if

    total = 1
    if (.not. info%is_directory .or. info%is_symlink) return

    children = scandir(path)
    do i = 1, size(children)
      total = total + count_walk_entries(children(i)%path)
    end do
  end function count_walk_entries

  recursive subroutine collect_walk_entries(path, depth, entries, next_index)
    character(len=*), intent(in) :: path
    integer, intent(in) :: depth
    type(directory_entry), intent(inout) :: entries(:)
    integer, intent(inout) :: next_index
    type(directory_entry), allocatable :: children(:)
    type(directory_entry) :: entry
    integer :: i

    entry = make_directory_entry(path, depth)
    entries(next_index) = entry
    next_index = next_index + 1

    if (.not. entry%info%is_directory .or. entry%info%is_symlink) return

    children = scandir(path)
    do i = 1, size(children)
      call collect_walk_entries(children(i)%path, depth + 1, entries, next_index)
    end do
  end subroutine collect_walk_entries

end module fgof_fs
