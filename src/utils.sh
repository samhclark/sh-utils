# shellcheck shell=sh

# Logging

## Basic printing

eprintln() {
    1>&2 printf "%s\n" "$*"
}


## Featureful logging

## Everything gets logged to STDERR on purpose.
## The utils in this repo use STDIN/STDOUT for input-output so I don't want to clutter it with logs.
## For simplicity's sake, this is using STDERR right now instead of systemd or MacOS's log.
__to_stderr_with_timestamp() {
    # POSIX date doesn't include %N for nanoseconds.
    1>&2 printf "%s %s\n" "$(date "+%Y-%m-%dT%T")" "$*"
}

log_info() {
    __to_stderr_with_timestamp "[INFO]: $*"
}

log_warn() {
    __to_stderr_with_timestamp "[WARN]: $*"
}

log_error() {
    __to_stderr_with_timestamp "[ERROR]: $*"
}

log_fatal_die() {
    __to_stderr_with_timestamp "[FATAL]: $*"
    exit 1
}


# Functional Programming tools 

var_to_stdout() {
    printf "%s\n" "$*"
}

observe_pipe() {
    awk '{print|"cat 1>&2";print}'
}

count() {
    wc -l | awk '{print $1}'
}

map() (
    fn="$*"
    while read -r line; do 
        var_to_stdout "$line" | eval " $fn"
    done
)

alias for_each=map

filter() (
    fn="$*"
    while read -r line; do 
        var_to_stdout "$line" | eval " $fn" \
            && var_to_stdout "$line"
    done
)

identity() {
    cat -
}

# Shell script testing helpers 

## Test scaffolding
__cleanup_tests() {
    trap - EXIT
    if [ -n "$tmpdir" ]; then rm -rf "$tmpdir"; fi
    if [ -n "$1" ]; then trap - "$1"; kill -"$1" $$; fi
}

setup_tmpdir() {
    trap '__cleanup_tests' EXIT
    trap '__cleanup_tests HUP' HUP
    trap '__cleanup_tests TERM' TERM
    trap '__cleanup_tests INT' INT

    # Not strictly POSIX, but seems supported on Linux, MacOS, OpenBSD, and FreeBSD
    mktemp -d
}

find_all_scripts_in_dir() {
    find "$1" -name '*.sh'
}

files_with_tag() {
    # /^#test\s*$/
    xargs grep -l "^${1}\s"'*$'
}

__list_all_tests_in_file() {
    awk 'f{print;f=0} /^#test\s*$/{f=1}' "$1" | sed 's/(.*$//'
}

run_all_tests_in_file() {
    current_test=$((1))
    filename="$(cat -)"

    log_info "Running all tests in $filename"
    # shellcheck source=/dev/null
    . "$filename"

    __list_all_tests_in_file "$filename" \
        | tee "$tmpdir/tests_in_progress" \
        | while read -r fn; do 
            header="$(printf "%s/%s '%s'" "$current_test" "$(count < "$tmpdir/tests_in_progress")" "$fn")"
            __run_with_header "$fn" "$header"
            current_test=$((current_test+1))
        done
}

__run_with_header() (
    method="$1"
    header="$2"
    if "$method"; then
        eprintln "$header: passed"
    else
        eprintln "$header: failed"
    fi
)

## Test methods
assert_eq() (
    expected="$1"
    actual="$2"

    if [ "$expected" != "$actual" ]; then 
        eprintln "assert_eq failed.
Expected
---
${expected}---

But was
---
${actual}---
"
        return 1
    fi
)