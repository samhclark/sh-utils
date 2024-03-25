# shellcheck shell=sh

# private id: __wwawx3

. "$(dirname "$0")/utils.sh"

n="
"

__wwawx3_three_char() {
    test "4" = "$(tee | wc -m)"
}

#test
__wwawx3_map_works() {
    # given
    input="$(printf "one\ntwo\nthree")$n"
    expected="$(printf "eno\nowt\neerht")$n"

    # when
    actual="$(printf "%s" "$input" | map rev)$n"

    # then
    assert_eq "$expected" "$actual" 
}

#test
__wwawx3_filter_works() {
    # given
    input="$(printf "one\ntwo\nthree")$n"
    expected="$(printf "one\ntwo")$n"

    # when
    actual="$(printf "%s" "$input" | filter __wwawx3_three_char)$n"

    # then
    assert_eq "$expected" "$actual" 
}
