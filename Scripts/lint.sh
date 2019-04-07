#!/bin/sh

#  lint.sh
#  Bootstrap
#

function getLint {
    local output
    declare -a POSSIBLE_LOCATIONS=(
        "${PROJECT_DIR}/Pods/SwiftLint/swiftlint"
        "`which swiftlint`"
    );
    for location in "${POSSIBLE_LOCATIONS[@]}"; do
        if [ -e "${location}" ]
            then
                output="${location}"
                break
        fi
    done
    echo $output
}

echo "Searching linter ..."
LINT_BINARY=$(getLint)
if [[ -z "${LINT_BINARY// }" ]]
    then
        echo "warning: Linter is not found"
        exit 0
    else
        echo "found at ${LINT_BINARY}"
fi

echo "Start linting at `pwd`"
$LINT_BINARY lint --config "${SRCROOT}/.swiftlint.yml" --strict
