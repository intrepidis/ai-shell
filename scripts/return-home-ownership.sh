#!/usr/bin/env bash
set -euo pipefail
# Relies on GNU coreutils: stat -c, realpath -e, chown --no-dereference, read -d ''
# Intended for GNU/Linux

usage() {
    printf '%s\n' \
        'Usage:' \
        '  return-home-ownership.sh --path PATH [PATH...]' \
        '  return-home-ownership.sh --paths-from-stdin' \
        '  return-home-ownership.sh --session --since-marker FILE [PATH...]' \
        '  return-home-ownership.sh --full-home' \
        '  return-home-ownership.sh --help'
}

if [[ ${EUID} -ne 0 ]]; then
    printf '%s\n' 'Not root; no-op.'
    exit 0
fi

die() {
    printf 'return-home-ownership: %s\n' "$*" >&2
    exit 1
}

resolve_target() {
    local requested_user=${SUDO_USER:-}
    local passwd_entry fallback_user

    if [[ -z $requested_user || $requested_user == root ]]; then
        requested_user=$(stat -c '%U' "$HOME") || die "cannot determine the owner of $HOME"
    fi
    passwd_entry=$(getent passwd "$requested_user" || true)
    if [[ -z $passwd_entry ]]; then
        fallback_user=$(stat -c '%U' "$HOME") || die "cannot determine the owner of $HOME"
        passwd_entry=$(getent passwd "$fallback_user" || true)
    fi
    [[ -n $passwd_entry ]] || die 'no resolvable non-root target account'

    IFS=: read -r target_user _ target_uid target_gid _ target_home _ <<< "$passwd_entry"
    [[ -n ${target_user:-} && -n ${target_uid:-} && -n ${target_gid:-} && -n ${target_home:-} ]] || die 'target account record is incomplete'
    # UID-0 fallback: if target resolves to UID 0, try the home owner; if that too is UID 0 → safe no-op
    if [[ $target_uid == 0 ]]; then
        local home_owner
        home_owner=$(stat -c '%U' "$HOME") || die "cannot determine the owner of $HOME"
        passwd_entry=$(getent passwd "$home_owner" || true)
        [[ -n $passwd_entry ]] || die 'home owner is not a resolvable account'
        IFS=: read -r target_user _ target_uid target_gid _ target_home _ <<< "$passwd_entry"
        [[ -n ${target_user:-} && -n ${target_uid:-} && -n ${target_gid:-} && -n ${target_home:-} ]] || die 'target account record is incomplete'
        if [[ $target_uid == 0 ]]; then
            printf '%s\n' 'No non-root target available; nothing to do (no-op).'
            exit 0
        fi
    fi
    local group_entry
    group_entry=$(getent group "$target_gid" || true)
    IFS=: read -r target_group _ _ _ <<< "$group_entry"
    [[ -n ${target_group:-} ]] || die 'cannot resolve target primary group'
    [[ -d $target_home ]] || die "target home does not exist: $target_home"
}

resolve_target
home_real=$(realpath -e -- "$target_home") || die "cannot resolve target home: $target_home"
printf 'Resolved target: %s (%s:%s), home %s\n' "$target_user" "$target_user" "$target_group" "$home_real"

chown_one() {
    local path=$1
    [[ -n $path ]] || die 'empty path is not allowed'
    [[ $path != / ]] || die 'refusing to chown /'

    local resolved
    resolved=$(realpath -- "$path") || die "cannot resolve path: $path"
    [[ $resolved == "$home_real" || $resolved == "$home_real"/* ]] || die "path is outside target home: $path"
    [[ -e $path || -L $path ]] || die "path does not exist: $path"
    chown --no-dereference "$target_user:$target_group" -- "$path" || die "failed to chown: $path"
    printf 'Repaired: %s\n' "$path"
}

chown_stdin() {
    local path
    while IFS= read -r path || [[ -n $path ]]; do
        if [[ -z $path ]]; then
            die 'empty path record is not allowed from stdin'
        fi
        chown_one "$path"
    done
}

mode=
case ${1:-} in
    --help) usage; exit 0 ;;
    --path) mode=path; shift; (($# > 0)) || die '--path requires at least one path' ;;
    --paths-from-stdin) mode=stdin; shift; (($# == 0)) || die 'unexpected arguments after --paths-from-stdin' ;;
    --session) mode=session; shift; [[ ${1:-} == --since-marker ]] || die '--session requires --since-marker FILE'; shift; [[ $# -gt 0 ]] || die '--since-marker requires FILE'; marker=$1; shift ;;
    --full-home) mode=full; shift; (($# == 0)) || die 'unexpected arguments after --full-home' ;;
    '') usage >&2; exit 1 ;;
    *) die "unknown option: $1" ;;
esac

case $mode in
    path)
        for path in "$@"; do chown_one "$path"; done
        ;;
    stdin)
        chown_stdin
        ;;
    session)
        [[ -f $marker ]] || die "marker is not a regular file: $marker"
        for path in "$@"; do chown_one "$path"; done
        marker_real=$(realpath -e -- "$marker") || die "cannot resolve marker: $marker"
        while IFS= read -r -d '' path; do
            [[ $path == "$marker_real" ]] && continue
            chown_one "$path"
        done < <(find -P "$home_real" -xdev -uid 0 -newer "$marker_real" ! -path "$marker_real" -print0)
        ;;
    full)
        [[ $home_real != / ]] || die 'refusing to recurse over root home /'
        printf 'Full-home ownership repair for %s (%s:%s): %s\n' "$target_user" "$target_user" "$target_group" "$home_real"
        chown --no-dereference -R "$target_user:$target_group" -- "$home_real" || die "failed to repair full home: $home_real"
        ;;
esac
