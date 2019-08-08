#!/bin/bash -e

VERSION="$1"
if [ -z "$VERSION" ]; then
   echo "Please specify version in command-line"
   exit 1
fi

#handle optional parent directory
PROD_REPO="$2"
if [ -z "$PROD_REPO" ]; then
    PROD_REPO="${HOME}/repos/production-rpms"
fi 
if [ ! -d $PROD_REPO ]; then
    echo "Unable to find production RPM repo at $PROD_REPO. You may need tto specify the correct path as the second command line option."
fi

WHEREAMI=`dirname $0`
MYCWD=`pwd`

PRODDIR_BASE="${PROD_REPO}/el7"
PRODDIR_SUFFIX="${VERSION}"
URL_BASE="https://perfsonar-dev3.grnoc.iu.edu/staging/el/7"
URL_SUFFIX="perfsonar/${VERSION}/packages"
ARCHS=( "x86_64" "SRPMS" )
TEMPDIR=`mktemp -d`

#update the repos
for ARCH in "${ARCHS[@]}"
do
    echo "[$ARCH]"
    
    #Build directory structure
    cd $MYCWD 
    ${WHEREAMI}/yum-repo-update $VERSION ${PRODDIR_BASE}/${ARCH}
    
    #prep for download
    cd ${TEMPDIR}
    PRODDIR="${PRODDIR_BASE}/${ARCH}/$PRODDIR_SUFFIX"
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
