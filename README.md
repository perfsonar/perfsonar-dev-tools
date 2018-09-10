# Development Tools for perfSONAR Developers

This directory contains standard client-side hooks for use with
perfSONAR Git repositories.


## Git Branch Closer

The `close-branch` program is used on release to prepare for
development of the next release by doing the following:

 * Creating branches for the next major, minor and bugfix releases if
   they do not already exist.  (For example, closing the `1.2.3`
   branch will create `2.0.0`, `1.3.0` and `1.2.4`.)

 * Adding a `BRANCH-CLOSED` file to the root of the repository.  This is
   used as a visual cue and hint to the Git hooks described below that
   commits should not be added to the current branch.

### Usage Examples

```
% cd ~/work/my-repository
% git checkout 1.2.3
% /path/to/tools/bin/close-branch
```


## Git Hook Installer

The `install-git-hooks` program installs Git client-side hooks to
detect attempts to commit 

Currently, these hooks do the following:

 * Abort commits on branches that have been closed to new commits if
   the file `BRANCH-CLOSED` is present in the root directory of the
   repository.  Note that this can by bypassed locally, but the
   perfSONAR GitHub repository will enforce closings if configured to
   do so.

 * Insert a commented warning in commit messages to that effect in
   case the abort-on-commit hook is bypassed.

### Usage Examples

```
% cd ~/work/my-repository
% /path/to/tools/bin/install-git-hooks`
```

```
% /path/to/tools/bin/install-git-hooks ~/work/my-repository`
```
