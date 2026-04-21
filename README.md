# fgof-fs

Filesystem and path helpers for modern Fortran tools.

`fgof-fs` is intended to be a small, standalone library that gives Fortran applications an ergonomic filesystem toolkit for paths, metadata, traversal, and common file operations.

It is the planned filesystem package in the `FortranGoingOnForty` library family, but it is intended to stand on its own as a normal `fpm` package.

## Status

Planning scaffold.

The repository is set up, the public package shape is being defined, and the first implementation pass will focus on a narrow but useful POSIX-first filesystem surface.

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

## Current Scaffold

Today the package only includes a tiny path and existence baseline:

- `join_path()` in `fgof_path`
- `path_exists()` in `fgof_fs`

Those functions are intentionally small. They keep the package buildable while the real API contract and sprint plan are being settled.

## Boundaries

- POSIX-first for macOS and Linux
- complement `stdlib_system` rather than trying to fight it
- keep the first release tight and broadly useful

## License

MIT
