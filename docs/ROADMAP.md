# Roadmap

## Current focus

- define a small ergonomic filesystem and path API
- extract the highest-value pieces from local app code without dragging app-specific design into the package
- keep the first release focused on the operations most app authors need immediately

## v0.1

- path joins and normalization helpers
- existence and file-kind checks
- metadata access
- directory listing and walking
- create, remove, copy, and move helpers
- documented POSIX-first library with examples and tests

## v0.2

- richer symlink handling
- filtering and ignore-aware walking
- globbing and pattern helpers
- stronger metadata and error reporting

## v0.3

- optional higher-level companions such as temp, trash-open, or XDG helpers
- deeper extraction from `fortress`, `sniffert`, and related tools
