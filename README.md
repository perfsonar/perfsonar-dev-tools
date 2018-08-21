# Git Hooks for perfSONAR Developers

This directory contains standard client-side hooks for use with
perfSONAR Git repositories.

Currently, these hooks do the following:

 * Abort commits on branches that have been closed to new commits if
   the file `BRANCH-CLOSED` is present in the root directory of the
   repository.  Note that this can by bypassed locally, but the
   perfSONAR GitHub repository will enforce closings if configured to
   do so.


# Installation

To install the hooks in a cloned copy of a repository, run the
`install` script with the path to the repository as the first
parameter.  (E.g., `./install ~/work/some-stuff`.)
