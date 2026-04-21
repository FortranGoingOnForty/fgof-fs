# fgof-fs

[![CI](https://github.com/FortranGoingOnForty/fgof-fs/actions/workflows/ci.yml/badge.svg)](https://github.com/FortranGoingOnForty/fgof-fs/actions/workflows/ci.yml)

Filesystem and path helpers for modern Fortran tools.

`fgof-fs` is intended to be a small, standalone library that gives Fortran applications an ergonomic filesystem toolkit for paths, metadata, traversal, and common file operations.

It is the planned filesystem package in the [FortranGoingOnForty lib-modules](https://github.com/FortranGoingOnForty/lib-modules) catalog, but it is intended to stand on its own as a normal `fpm` package.

## Status

Path, metadata, discovery, and first write-side helpers are in place.

The repository already has a usable v1 slice for tool authors. The current work is mostly hardening, API polish, and release-shape refinement rather than basic capability.

Implemented today:

- public `fgof_path` and `fgof_fs` modules
- path helpers: `join_path()`, `basename()`, `dirname()`, `normalize_path()`
- filesystem metadata: `exists()`, `path_exists()`, `is_file()`, `is_directory()`, `is_symlink()`, `stat()`, `lstat()`
- discovery helpers: `current_dir()`, `scandir()`, `walk()`
- mutation helpers: `mkdir_p()`, `remove_file()`, `remove_tree()`, `move_path()`, `copy_file()`
- command discovery: `which()`

Likely follow-on or separate-package scope:

- temp files and atomic write helpers
- trash and "open with default app" helpers
- XDG and app-state directory helpers
- ignore rules and advanced globbing

## Why Use It

- it gives Fortran app authors an obvious default for common filesystem tasks
- metadata, traversal, mutation, and command lookup live behind one small API
- discovery behavior is deterministic: `scandir()` is sorted lexically and `walk()` is stable depth-first
- symlink behavior is explicit instead of surprising
- the package is aimed at shells, editors, file tools, test fixtures, and developer tooling rather than numerics

## Public API Shape

Modules:

- `fgof_path`
- `fgof_fs`

Types:

- `directory_entry`
- `path_info`

## Quick Start

```fortran
program demo_fs
  use fgof_fs, only : copy_file, current_dir, directory_entry, scandir, stat, which
  use fgof_path, only : join_path, normalize_path
  implicit none

  type(directory_entry), allocatable :: entries(:)

  print "(A)", join_path("alpha", "beta.txt")
  print "(A)", normalize_path("./tmp/../example.txt")
  print "(A)", current_dir()
  print *, stat("README.md")%size
  print "(A)", which("sh")

  if (copy_file("README.md", "/tmp/fgof-fs-readme-copy.txt")) then
    print *, "copied"
  end if

  entries = scandir("src")
  print *, size(entries)
end program demo_fs
```

## Build And Test

```bash
fpm test
```

That is the baseline verification command locally and in CI.

## Common Patterns

Walk a tree:

```fortran
type(directory_entry), allocatable :: entries(:)
entries = walk("src")
```

Create parent directories:

```fortran
if (.not. mkdir_p("build/cache/state")) error stop "mkdir_p failed"
```

Move or copy regular files:

```fortran
if (.not. move_path("draft.txt", "final.txt")) error stop "move failed"
if (.not. copy_file("final.txt", "backup.txt")) error stop "copy failed"
```

Resolve a tool from `PATH`:

```fortran
character(len=:), allocatable :: sh_path
sh_path = which("sh")
```

## Current Semantics

Discovery:

- `scandir()` returns direct children only
- `scandir()` returns entries in lexical order
- `walk()` returns a flat depth-first listing with the root entry first
- `walk()` does not recurse into symlink roots or symlink children in the current implementation

Mutation and lookup:

- `move_path()` uses POSIX rename behavior and overwrites plain destination files when the platform allows it
- `copy_file()` copies regular file contents and overwrites plain destination files
- `copy_file()` rejects directory and symlink sources or destinations in the current implementation
- `copy_file()` does not create parent directories implicitly
- `remove_tree()` removes symlink entries inside a tree without removing the symlink targets they point to
- `which()` resolves direct executable paths and searches `PATH` for bare command names

## Supported Platforms

- macOS
- Linux
- GitHub Actions CI runs `fpm test` on `macos-latest` and `ubuntu-latest` with the GCC Fortran toolchain and `fpm v0.13.0`

## Boundaries

- POSIX-first for macOS and Linux
- complements `stdlib_system` rather than trying to replace or fight it
- keeps the first release tight and broadly useful

## License

MIT
