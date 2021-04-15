#!/bin/bash
# using bash wrapper as Rake blows up in `require/extentiontask` (line 10)

RELEASE_FLAGS=""
if [ -e "$TRAVIS_REPO_SLUG" ]; then
    RELEASE_FLAGS="-r git+https://github.com/${TRAVIS_REPO_SLUG}.git"
fi 

set -x
exec semantic-release $RELEASE_FLAGS

