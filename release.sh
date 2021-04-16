#!/bin/bash
# using bash wrapper as Rake blows up in `require/extentiontask` (line 10)

RELEASE_FLAGS=""
if [ ! -z "$TRAVIS_REPO_SLUG" ]; then
    RELEASE_FLAGS="-r git+https://github.com/${TRAVIS_REPO_SLUG}.git"
fi 

if [ ! -z "$GEM_ALTERNATIVE_NAME" ]; then
    echo "Release: GEM_ALTERNATIVE_NAME=$GEM_ALTERNATIVE_NAME"
fi

set -x
exec semantic-release $RELEASE_FLAGS

