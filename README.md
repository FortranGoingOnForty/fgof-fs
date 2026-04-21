# fgof-fs

Filesystem and path helpers for modern Fortran tools.

`fgof-fs` is intended to be a small, standalone library that gives Fortran applications an ergonomic filesystem toolkit for paths, metadata, traversal, and common file operations.

It is the planned filesystem package in the `FortranGoingOnForty` library family, but it is intended to stand on its own as a normal `fpm` package.

## Status

Path, metadata, discovery, and first write-side helpers are in place.

The repository is set up, the package builds cleanly, and the first path, metadata, traversal, mutation, and command-discovery helpers are implemented and tested. The next major steps are hardening examples, tightening edge-case semantics, and reviewing the first tagged release surface.

Current v1 target:

- path joins and normalization helpers
- existence and kind checks
- `stat` and `lstat` style metadata
- directory listing and recursive walking
- file and directory mutations such as create, remove, copy, and move
- practical helpers such as `current_dir` and `which`

Likely follow-on or separate-package scope:

- temp files and atomic write helpers
- trash and "open with default app" helpers
- XDG and app-state directory helpers
- ignore rules and advanced globbing

## Why This Package

- there is still no obvious default ergonomic filesystem toolkit for Fortran app authors
- shells, editors, file tools, and developer tooling all need this repeatedly
- the local FortranGoingOnForty codebase already contains strong extraction candidates in `fortress`, `sniffert`, and `fortsh`

## Planned Public Modules

- `fgof_path`
- `fgof_fs`

## Build And Test

```bash
fpm test
```

## Current Surface

Today the package includes a small but real path, metadata, and discovery baseline:

- `join_path()` in `fgof_path`
- `basename()` in `fgof_path`
- `dirname()` in `fgof_path`
- `normalize_path()` in `fgof_path`
- `type(directory_entry)` in `fgof_fs`
- `type(path_info)` in `fgof_fs`
- `exists()` and `path_exists()` in `fgof_fs`
- `is_file()` in `fgof_fs`
- `is_directory()` in `fgof_fs`
- `is_symlink()` in `fgof_fs`
- `stat()` and `lstat()` in `fgof_fs`
- `current_dir()` in `fgof_fs`
- `scandir()` in `fgof_fs`
- `walk()` in `fgof_fs`
- `mkdir_p()` in `fgof_fs`
- `remove_file()` in `fgof_fs`
- `remove_tree()` in `fgof_fs`
- `move_path()` in `fgof_fs`
- `copy_file()` in `fgof_fs`
- `which()` in `fgof_fs`

These functions are intentionally compact. They already give the package a usable slice for tooling work while the broader filesystem API is still being shaped.

## Current Example

```fortran
use fgof_fs, only : copy_file, current_dir, directory_entry, exists, scandir, stat, which
use fgof_path, only : basename, dirname, join_path, normalize_path

type(directory_entry), allocatable :: entries(:)

print "(A)", join_path("alpha", "beta.txt")
print "(A)", basename("/tmp/example.txt")
print "(A)", dirname("/tmp/example.txt")
print "(A)", normalize_path("./tmp/../example.txt")
print "(A)", current_dir()
print *, exists("README.md")
print *, stat("README.md")%size
print "(A)", which("sh")
print *, copy_file("README.md", "/tmp/fgof-fs-readme-copy.txt")
entries = scandir("src")
print *, size(entries)
```

Discovery semantics in the current implementation:

- `scandir()` returns direct children only
- `walk()` returns a flat depth-first listing with the root entry first
- `walk()` does not recurse into symlinks in the first pass

Mutation and lookup semantics in the current implementation:

- `move_path()` renames files or directories in one step
- `copy_file()` copies regular file contents and overwrites plain destination files
- `copy_file()` rejects directory and symlink sources or destinations in the first pass
- `which()` resolves direct executable paths and searches `PATH` for bare command names

## Boundaries

- POSIX-first for macOS and Linux
- complement `stdlib_system` rather than trying to fight it
- keep the first release tight and broadly useful

## License

MIT
