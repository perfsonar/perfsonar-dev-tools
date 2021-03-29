# Development Tools for perfSONAR Developers

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

# Release support scripts

These are the scripts one should use to deal with making a release and preparing repositories for the subsequent release.

## To make a release
**NOTE: Full details on the release proccess are [here](https://github.com/perfsonar/project/wiki/Release-Process)**

Usually it is used in the following way (for release `4.2.3` as example):
- Call to `make-release 4.2.3 -r 1`
  - Will create the release files and the release tags
  - Will merge this release changes in the next release branches if they are existing  (i.e. 4.3.x)
- Call to `close-release 4.2.3`
  - Will close the 4.2.3 branch
  - Will create the next version branches if they are not existing (i.e. 4.3.x and 4.2.4).

### All repos: make-release
- If it's a final release (with `-r 1`)
  - call `merge-forward` to merge all repos in future releases branches
- Work in a temporary directory
- Loop on all repos/projects
  - Clone repo
  - Call `make-repo-release`
  - Do a git **push with tags** if succesful

### One repo: make-repo-release
The `make-repo-release` program try to release new packages from a 
perfSONAR repository.  It always  takes  an  argument: the VERSION to be
released. There is another mandatory option, `-r` which states the RELNUM.
It has additional options which ore documented in the script `-h`.

This program enforces the [version numbering as specified in our policy](https://github.com/perfsonar/project/wiki/Versioning
"perfSONAR package numbering").

- Release final, RC, beta or alpha of packages existing in a single repository
- Change RPM and debian files
- Do a git commit and add tags

#### Usage examples

Making a beta release:
```
% cd ~/work/my-repository
% /path/to/tools/bin/make-repo-release -r 0.b1.2 -d 1 -g 4.2.0
```

Making a final release:
```
% cd ~/work/my-repository
% /path/to/tools/bin/make-repo-release -r 1 -d 1 -g 4.2.0
```

Making a RPM only release:
```
% cd ~/work/my-repository
% /path/to/tools/bin/make-repo-release -r 2 -g 4.2.0
```

Making a Debian only release:
```
% cd ~/work/my-repository
% /path/to/tools/bin/make-repo-release -r 1 -d 2 -g 4.2.0
```

## To close a release branch
The `close-branch` program is used **after release** to prepare for
development of the next release by doing the following:

 * Creating branches for the next major, minor and bugfix releases if
   they do not already exist.  (For example, closing the `1.2.3`
   branch will create `2.0.0`, `1.3.0` and `1.2.4`.)

 * Adding a `BRANCH-CLOSED` file to the root of the repository.  This is
   used as a visual cue and hint to the Git hooks described below that
   commits should not be added to the current branch.

### close-release
- Takes a VERSION as parameter
- Work in a temporary directory
- Loop on all repos/projects
  - Clone repo
  - Call `close-branch`

### close-branch
- Call `create-next-versions` to make sure the next version branch is existing
- Loop on all `next-versions`
  - Call `merge-repo-forward` to merge the closing branch to the `next-versions`
  - Git **push** the merged forward `next-versions` branch if successful
- Add a `BRANCH-CLOSED` file to the repo (used by the git-hooks hereabove)
- Do a git commit and a **push**

#### Usage Examples

```
% cd ~/work/my-repository
% git checkout 1.2.3
% /path/to/tools/bin/close-branch
```

## Internals
The following scripts are used internally by the above described scripts, but shouldn't normally be called by themselves.

### One repo: merge-repo-forward
The `merge-repo-forward` program try to merge changes from a lower release branch to the current branch. It works on a single repository. It always takes an argument: the VERSION to be merged, which needs to be lower than the current branch version. If a tag for the lower VERSION exists the tag will be merged, otherwise it is the tip of the lower VERSION branch that is merged in the current (higher version) branch.

It first tries to do a straight `git merge` (which also do a commit) and exit if all is fine.

If the straight merge doesn't work and a tag is being merged (i.e.: it is a released version that is to be merged forward), then this script tries to take care of all known differences that can happen between the branches. It currently catters for changes in RPM `*.spec` files, `Makefile` files, `configure.ac` files and `debian/changelog` files.  For the `pscheduler` repositories, it does that for all sub-directories. All the changes are then added in a single commit to the repository.

If the straight merge doesn't work and it's not a tag that is being merged, then the script exits and ask for a manual merge.

### create-next-versions
To run from a release branch, i.e. X.Y.Z.

- Loop on all next-versions numbers
  - Create new branch
  - Call `rpm_set_version`
  - Call `deb_set_new_version`
  - Do a git commit and a **push**

#### Usage examples:

To create branch 4.2.1 and 4.3.0:
```
(git:4.2.0)$ ../perfsonar-dev-tools/bin/create-next-versions
```

To create branch 4.2.3 from 4.2.1 (skipping 4.2.2):
```
(git:4.2.1)$ MYNEXTVERSIONS="4.2.3" ../perfsonar-dev-tools/bin/create-next-versions
```

## Merge a release into an already existing branch for future release

### merge-forward
- Loop on all repos/projects
  - Clone repo
  - Loop on all next-versions numbers
    - Call `merge-repo-forward`
    - Do a git **push** if succesful

### merge-repo-forward
To run from a higher release branch with a reference from an existing tag on the master branch.

- Merge a patch release into a higher version branch
- Take care of conflicts on RPM and debian files
- Do a git commit

#### Usage examples:

To merge latest released branch 4.2.2 (with tag from master) into 4.3.0
```
(git:4.3.0)$ ../perfsonar-dev-tools/bin/merge-repo-forward 4.2.2
```

