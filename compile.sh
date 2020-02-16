#!/bin/bash

# So we can see what we're doing
set -x

# Exit with nonzero exit code if anything fails
set -e

# Run bikeshed.  If there are errors, exit with a non-zero code
bikeshed --print=plain -f spec

# The out directory should contain everything needed to produce the
# HTML version of the spec.  Copy things there if the directory exists.

echo "Bikeshed ran"
if [ -d out ]; then
    echo "Copying index.html"
    cp index.html out
fi

