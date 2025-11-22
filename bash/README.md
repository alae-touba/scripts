This directory holds the helper scripts that keep a WSL development shell aligned with the workflow for this repository.

## Quick start

1. Copy `bash/bin/setup` from this GitHub repo onto the machine you are bootstrapping (e.g., `curl -o /tmp/setup.sh https://raw.githubusercontent.com/alae-touba/scripts/master/bash/bin/setup`), then make it executable (`chmod +x /tmp/setup.sh`).
2. Run the copied script (`/tmp/setup.sh`). It installs required packages (including Git), NVM, SDKMAN/Java, Maven, Starship, workspace folders, and clones `https://github.com/alae-touba/scripts` into `~/work/github/scripts`. It also runs `bash/install-aliases` so the repo’s aliases and `bash/bin` end up on your `PATH`.
3. After the script finishes, run `~/work/github/scripts/bash/git_local_conf` to set the repo’s local Git user.name/user.email if needed.
4. Source your shell config (`source ~/.bashrc`) or open a new terminal window so the new aliases and PATH take effect.

> `bash/bin/setup` is idempotent: it reuses `~/work/github/scripts` if already cloned, re-runs the aliases installer, and can be run again later to refresh tooling or fix anything that drifts.

## Aliases & PATH

Custom shortcuts live in `bash/.bash_aliases`; edit that file to add or remove aliases, then re-run `bash/install-aliases` if the file should be re-sourced and `bash/bin` re-added to `PATH`.

Some highlights shipped by default:
- Docker shortcuts (`dps`, `dpsa`, `di`, etc.)
- Git helpers (`gs`, `gpush`, `glog`, ...)
- Maven helpers (`mc`, `mci`, `mrun`, `mtree`, ...)
- Navigation helpers (`work`, `github`, `scripts`, `reload`, etc.)

## Utility scripts

`bash/bin` contains lightweight helpers you can rely on anywhere:

- `bash/bin/setup`: installs core tooling, NVM/Node.js, SDKMAN/Java, Maven, Starship, workspace folders, and ensures aliases are installed.
- `bash/git_local_conf`: sets per-repo Git user.name/user.email and shows the resulting local config.
- `bash/install-aliases`: backs up `~/.bashrc`, removes stale lines, then appends the alias source and `bash/bin` to `PATH`.
- `bash/bin/gitsync`: stages, commits (with a timestamped message), and pushes all local changes in a repo.
- `bash/bin/showversions`: displays versions for Java, Maven, Node.js, Docker, Git, Python, Go, and other tools (optionally filtered).
- `bash/bin/sysinfo`: reports host, memory, CPU, disk, network, and Docker status with WSL-aware warnings.
- `bash/bin/portls`, `bash/bin/portkill`, `bash/bin/portkillf`: list or terminate processes that listen on a specific TCP port.
