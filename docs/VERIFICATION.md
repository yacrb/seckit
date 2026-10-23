# SecKit verification

Run the repository-owned checks without fetching tools or changing system packages:

```sh
for script in bootstrap.sh scripts/*/*.sh tests/*.sh; do bash -n "$script"; done
shellcheck --severity=error bootstrap.sh scripts/*/*.sh tests/*.sh
bash tests/bootstrap_helpers.sh
./bootstrap.sh --help
./bootstrap.sh --check
```

The final command reports missing prerequisites with exit status 1. A leading
`-` in submodule status means that checkout is not initialized. It is a local
read-only check, not an installation or upstream availability test.

## What is exercised

- Bash syntax for the bootstrap, common library and wrappers.
- ShellCheck's error-level diagnostics; a pass does not mean every warning is fixed.
- Executable bits on installed entry scripts.
- Generated launchers with spaces and literal shell characters in paths/arguments.
- Preservation of existing user files and symlinks.
- Repeatable creation of the same launcher link.

## What still needs a dedicated lab

The full apt/pip/Go bootstrap, every upstream repository, actual scan behavior,
DFIR outputs and Windows-only GUI tools are not validated by this CI workflow.
Python installation currently uses `pip --user`; distributions enforcing an
externally managed Python environment can reject those steps. The failure summary
must be reviewed instead of treating partial setup as a successful installation.

Submodules and the existing scheduled updater retain upstream branch behavior.
The bootstrap also installs dnsx using `@latest` and refreshes nuclei templates.
Those external dependencies are not a fully locked, reproducible toolchain.
Tool compatibility, system-package changes and dependency conflicts need testing
on the actual lab distribution.

Review scripts before using them on case evidence. Several wrappers write
extracted data into their output directories; they are triage conveniences rather
than a forensic chain-of-custody or write-blocking system.
