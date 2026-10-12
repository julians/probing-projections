#!/usr/bin/env bash
# Builds a static version of the prototype into ./dist without the original
# grunt/compass toolchain. Needs a current node.js (npx fetches the rest).
#
#   ./build.sh            builds ./dist
#   ./build.sh serve      builds and serves ./dist on http://localhost:9000
#
# The result has to be served over http (the templates are loaded with
# XHR), any static file server will do.
set -euo pipefail
cd "$(dirname "$0")"

echo "» installing frontend dependencies (bower)"
npx -y bower install --config.interactive=false

echo "» compiling coffeescript"
rm -rf dist
mkdir -p dist/scripts dist/styles
npx -y -p coffeescript@1.12.7 coffee -c -o dist/scripts app/scripts
(cd app/scripts && find . \( -name "*.js" -o -name "*.html" -o -name "*.json" \) | while read -r file; do
    mkdir -p "../../dist/scripts/$(dirname "$file")"
    cp "$file" "../../dist/scripts/$file"
done)

echo "» compiling sass"
npx -y sass@1.77.8 --quiet --quiet-deps --load-path=app/styles --no-source-map app/styles/main.scss dist/styles/main.css

echo "» copying assets"
cp -R app/images dist/images
cp -R app/bower_components dist/bower_components
cp app/index.html dist/index.html

echo "» done: ./dist"

if [ "${1:-}" = "serve" ]; then
    echo "» serving on http://localhost:9000"
    python3 -m http.server 9000 --directory dist
fi
