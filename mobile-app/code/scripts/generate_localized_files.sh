#!/bin/bash 
set -e

echo "------------------------------------------------------------------------"
echo "Generating localized strings"
echo "------------------------------------------------------------------------"

fvm flutter gen-l10n
fvm dart format -l 80 .
