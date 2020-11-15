#!/bin/sh -e

WHEREAMI=$(dirname $0)
. "${WHEREAMI}/common"

# Version to reverse to (TAG)
VERSION="stretch/4.3.0"

# Get current branch
BRANCH=`git branch --list | awk '/^\* .*$/ {print $2}'`

# Reverse faulty changelog entries
if grep -qs '(native)' debian/source/format ; then
    git checkout debian/${VERSION} -- debian/changelog
else
    git checkout debian/${VERSION}-1 -- debian/changelog
fi

# And generate debian/changelog and debian/gbp.conf again
rpm_set_version "$BRANCH" "0.a1.0"
deb_set_new_version "$BRANCH" "0.a1.0"
git commit -m "Correcting debian/changelog for upcoming $BRANCH version."

