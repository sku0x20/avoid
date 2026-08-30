#!/bin/sh
# Find packages in packages.list that are already pulled in as deps by others in the list.

pkgs=$(grep -v '^#' packages.list | grep -v '^$')

all_deps=""
for pkg in $pkgs; do
    deps=$(xbps-query -Rx "$pkg" 2>/dev/null | sed 's/[><=].*//')
    all_deps="$all_deps
$deps"
done

echo "Implicit (already pulled in by others):"
for pkg in $pkgs; do
    if echo "$all_deps" | grep -qx "$pkg"; then
        echo "  $pkg"
    fi
done
