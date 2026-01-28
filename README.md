# slinux

A basic Linux distro using musl, sbase+ubase, and sinit

## Building

> [!NOTE]
> GNU Bash is required in order to run these scripts.

To configure, edit `config.sh`

To build slinux and create an slinux.iso, run `build.sh`

## Hacking

When writing C specifically for slinux (e.g. rc.shutdown), use
[the suckless coding style](https://suckless.org/coding_style/).

## Software in the base system

- linux
- musl
- sbase
- ubase
- sinit
- dash
- oksh