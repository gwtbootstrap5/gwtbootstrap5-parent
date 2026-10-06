#!/usr/bin/env bash
#
# Releases GwtBootstrap5 from the four repositories of this checkout.
#
#   ./release.sh 0.2.1                 sets the version, moves the Unreleased section of
#                                      CHANGELOG.md under it, commits, tags v0.2.1 in the four
#                                      repositories and pushes. The parent's tag starts the
#                                      release workflow, which publishes to Maven Central.
#   ./release.sh --next 0.2.2-SNAPSHOT sets the next development version, commits and pushes.
#
# Pushes go over SSH. The demo is pushed after the parent's master, because its Pages build
# compiles against the master of the other repositories, and the parent's tag goes last,
# because the release workflow checks out the tagged commits of the submodules.
set -euo pipefail

cd "$(dirname "$0")"

VERSIONS_PLUGIN=org.codehaus.mojo:versions-maven-plugin:2.22.0
ORG=git@github.com:gwtbootstrap5
# local path and GitHub repository of each submodule
SUBMODULES=(gwtbootstrap5:gwtbootstrap5 gwtbootstrap5-extras:gwtbootstrap5-extras gwtbootstrap5-demo:gwtbootstrap5.github.io)
PARENT_REPO=gwtbootstrap5-parent

die() { echo "release.sh: $*" >&2; exit 1; }

usage() {
    echo "usage: $0 X.Y.Z | --next X.Y.Z-SNAPSHOT" >&2
    exit 2
}

# Fails unless every repository is clean, on master and level with GitHub
check_repos() {
    local path
    for path in . "${SUBMODULES[@]%%:*}"; do
        [ -z "$(git -C "$path" status --porcelain --ignore-submodules=all)" ] || die "$path has uncommitted changes"
        [ "$(git -C "$path" rev-parse --abbrev-ref HEAD)" = master ] || die "$path is not on master"
        git -C "$path" fetch -q origin master
        [ "$(git -C "$path" rev-parse HEAD)" = "$(git -C "$path" rev-parse origin/master)" ] \
            || die "$path is not level with origin/master"
    done
}

set_version() {
    mvn -B -q "$VERSIONS_PLUGIN:set" -DnewVersion="$1" -DgenerateBackupPoms=false -DprocessAllModules=true
}

commit_all() {
    local message="$1" path
    for path in "${SUBMODULES[@]%%:*}"; do
        git -C "$path" commit -q -am "$message"
    done
    git add pom.xml CHANGELOG.md "${SUBMODULES[@]%%:*}"
    git commit -q -m "$message"
}

push_masters() {
    local entry
    for entry in "${SUBMODULES[@]:0:2}"; do
        git -C "${entry%%:*}" push -q "$ORG/${entry#*:}.git" master:master
    done
    git push -q "$ORG/$PARENT_REPO.git" master:master
    entry=${SUBMODULES[2]}
    git -C "${entry%%:*}" push -q "$ORG/${entry#*:}.git" master:master
}

confirm() {
    local answer
    read -r -p "$1 [y/N] " answer
    [ "$answer" = y ] || [ "$answer" = Y ] || die "stopped; nothing was pushed (undo the local commits and tags yourself)"
}

release() {
    local version="$1" tag="v$1" entry
    [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "the version must look like 1.2.3"
    check_repos
    for entry in ".:$PARENT_REPO" "${SUBMODULES[@]}"; do
        git ls-remote --exit-code -q "$ORG/${entry#*:}.git" "refs/tags/$tag" >/dev/null \
            && die "$tag already exists in ${entry#*:}"
    done
    grep -q '^## Unreleased$' CHANGELOG.md || die "CHANGELOG.md has no '## Unreleased' section"
    awk '/^## Unreleased$/ {s=1; next} /^## / {s=0} s && NF' CHANGELOG.md | grep -qvx 'Nothing yet\.' \
        || die "the Unreleased section of CHANGELOG.md is empty"

    set_version "$version"
    # The Unreleased notes become this version's section, under a new empty Unreleased
    sed -i "s/^## Unreleased\$/## Unreleased\n\nNothing yet.\n\n## $version ($(date +%F))/" CHANGELOG.md
    commit_all "Release $version"
    for entry in . "${SUBMODULES[@]%%:*}"; do
        git -C "$entry" tag -a "$tag" -m "GwtBootstrap5 $version"
    done

    echo "Committed and tagged $tag in the four repositories."
    confirm "Push now? The release workflow publishes $version to Maven Central, which can't be undone."
    push_masters
    for entry in "${SUBMODULES[@]}"; do
        git -C "${entry%%:*}" push -q "$ORG/${entry#*:}.git" "$tag"
    done
    git push -q "$ORG/$PARENT_REPO.git" "$tag"
    echo "Pushed. Follow the release at https://github.com/gwtbootstrap5/$PARENT_REPO/actions"
}

next() {
    local version="$1"
    [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+-SNAPSHOT$ ]] || die "the version must look like 1.2.3-SNAPSHOT"
    check_repos
    set_version "$version"
    commit_all "Start $version"
    confirm "Push the $version commits?"
    push_masters
    echo "Pushed $version."
}

case "${1:-}" in
    --next) [ $# -eq 2 ] || usage; next "$2" ;;
    -*|"") usage ;;
    *) [ $# -eq 1 ] || usage; release "$1" ;;
esac
