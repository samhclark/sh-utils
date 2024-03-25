# just manual: https://github.com/casey/just/#readme

_default:
    @just --list

# Runs lint and tests against all source files
check:
    find src -name '*.sh' | xargs shellcheck -P src
    src/run
