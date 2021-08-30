#!/bin/sh -e
# This is a temporary script that has been used to correct the debian/changelog
# in the 4.3.5 and 4.4.0 branches.  It shouldn't be used anymore as is but might
# come handy if similar issue arise in the future.

WHEREAMI=$(dirname $0)
. "${WHEREAMI}/common"

# Version to reverse to (TAG)
#VERSION="stretch/4.4.0"

# We work on branch 4.4.0
git checkout 4.3.5; git pull
git checkout 4.4.0; git pull

# Get current branch
BRANCH=`git branch --list | awk '/^\* .*$/ {print $2}'`
MYDIR="."

# Remove bad first line
#perl -ni -e 'print unless $. ==  1' debian/changelog

# We get back the correct debian/changelog history
#git checkout origin/4.3.0 -- debian/changelog
#vi -s ../4.3.5-correct.vim debian/changelog
#git diff -U0 origin/4.3.1 origin/4.3.2 -- debian/changelog | git apply --unidiff-zero
#git diff -U0 origin/4.3.1 origin/4.3.3 -- debian/changelog | git apply --unidiff-zero
#git diff -U0 origin/4.3.1 origin/4.3.4 -- debian/changelog | git apply --unidiff-zero
#git add debian/changelog
#git commit -m "Restoring a correct history for debian/changelog"

# Regenerate debian/gbp.conf
deb_set_new_version "$BRANCH" "0.a1.0"
git commit -m "Correcting debian/changelog for upcoming $BRANCH version."

