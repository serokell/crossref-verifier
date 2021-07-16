# SPDX-FileCopyrightText: 2020 Tocqueville Group
#
# SPDX-License-Identifier: MIT

# This script checks whether cabal.project and cabal.project.freeze files are up-to-date.
# It expects `stack2cabal` executable to be available in `$PATH`.

set -euo pipefail

files=(cabal.project cabal.project.freeze)

for file in "${files[@]}"; do
    mv "$file" "$file.orig"
done

stack2cabal

for file in "${files[@]}"; do
    set +e
    diff_res=$(diff "$file" "$file.orig")
    code=$?
    set -e
    if [ "$code" -ne 0 ]; then
        echo "file \"$file\" has changed, the diff is:"
        echo "$diff_res"
        echo "You need to run scripts/generate-cabal-files.sh to update this file"
        exit $code
    else
        echo "\"$file\" is up-to-date"
    fi
done
