#!/bin/bash -e

VERSION="$1"
if [ -z "$VERSION" ]; then
   echo "Please specify version in command-line"
   exit 1
fi

EL_VERSION="$2"
if [ -z "$EL_VERSION" ]; then
   echo "Please specify EL version in command-line"
   exit 1
fi

#specify 'ol' for Oracle Linux
DISTRO_TAG="$3"
if [ -z "$DISTRO_TAG" ]; then
   DISTRO_TAG="el"
fi

#Target directory is different when DISTRO_TAG is 'ol'. Still want it to go to el.
DISTRO_TAG_TARGET="$DISTRO_TAG"
if [ "$DISTRO_TAG" == "ol" ]; then
    DISTRO_TAG_TARGET="el"
fi

#handle optional parent directory
PROD_REPO="$4"
if [ -z "$PROD_REPO" ]; then
    PROD_REPO="${HOME}/repos/production-rpms"
fi 
if [ ! -d $PROD_REPO ]; then
    echo "Unable to find production RPM repo at $PROD_REPO. You may need tto specify the correct path as the second command line option."
fi

WHEREAMI=`dirname $0`
MYCWD=`pwd`

PRODDIR_BASE="${PROD_REPO}/${DISTRO_TAG_TARGET}${EL_VERSION}"
PRODDIR_SUFFIX="${VERSION}"
URL_BASE="https://perfsonar-dev3.grnoc.iu.edu/staging/${DISTRO_TAG}/${EL_VERSION}"
URL_SUFFIX="perfsonar/${VERSION}/packages"
ARCHS=( "x86_64" "SRPMS" )
TEMPDIR=`mktemp -d`

#setup proper rpm signature settings
RPMMACROS_PATH="${HOME}/.rpmmacros.${EL_VERSION}"
if [ -f $RPMMACROS_PATH ]; then
   cp -f ${RPMMACROS_PATH} ${HOME}/.rpmmacros
fi

#update the repos
for ARCH in "${ARCHS[@]}"
do
    echo "[$ARCH]"
    
    #Build directory structure
    PRODDIR="${PRODDIR_BASE}/${ARCH}/$PRODDIR_SUFFIX"
    mkdir -p ${PRODDIR}/packages
    cd ${PRODDIR_BASE}/${ARCH}
    ${WHEREAMI}/yum-repo-update $VERSION ${PRODDIR_BASE}/${ARCH}
    
    #prep for download
    cd ${TEMPDIR}
    URL="${URL_BASE}/${ARCH}/$URL_SUFFIX"
    
    # Download all the packages
    echo "Downloading packages from ${URL}..."
    ##note: change the --cut-dirs value if URL path ever changes
    wget -r -np -nH --cut-dirs=7 -A rpm $URL

    # Sign the packages
    echo "Signing packages..."
    rpmsign --resign *.rpm
    
    #move to production
    echo "Moving to ${PRODDIR}/packages..."
    mv *.rpm ${PRODDIR}/packages
    
    echo "Creating yum repo" 
    createrepo $PRODDIR
    
    echo ""
done

rm -rf ${TEMPDIR}
echo "Done"
