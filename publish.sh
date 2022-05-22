#!/bin/sh

set -e

COLOR_RED='\033[0;31m'          # Red
COLOR_GREEN='\033[0;32m'        # Green
COLOR_YELLOW='\033[0;33m'       # Yellow
COLOR_BLUE='\033[0;94m'         # Blue
COLOR_PURPLE='\033[0;35m'       # Purple
COLOR_OFF='\033[0m'             # Reset

run() {
    printf '%b\n' "${COLOR_PURPLE}==>${COLOR_OFF} ${COLOR_GREEN}$*${COLOR_OFF}"
    eval "$*"
}

die() {
    printf '%b\n' "${COLOR_RED}💔  $*${COLOR_OFF}" >&2
    exit 1
}

die_if_command_not_found() {
    for item in $@
    do
        command -v $item > /dev/null || die "$item command not found."
    done
}

die_if_command_not_found tar gzip git gh tar xz

run cd "$(dirname "$0")"

run pwd

unset TEMP_DIR
unset OUTPUT_DIR

unset RELEASE_VERSION
unset RELEASE_TARFILE

RELEASE_VERSION="$(date +%Y.%m.%d)"

OUTPUT_DIR="ppkg-core-$RELEASE_VERSION-macos-x86_64"
TEMP_DIR=$(mktemp -d)

run rm -rf     "$OUTPUT_DIR"
run install -d "$OUTPUT_DIR"

unset CORE_TOOL_BASENAME

for item in *.tar.xz
do
    case $item in
        openssl-*.tar.xz)
            ;;
        util-linux-*.tar.xz)
            tar vxf "$item" --strip-components=1 -C "$TEMP_DIR"
            ;;
        gnu-coreutils-*.tar.xz)
            tar vxf "$item" --strip-components=1 -C "$TEMP_DIR"
            ;;
        *)  tar vxf "$item" --strip-components=1 -C "$OUTPUT_DIR"
            if [ -z "$CORE_TOOL_BASENAME" ] ; then
                CORE_TOOL_BASENAME="$(basename "$item" -macos-x86_64.tar.xz)"
            else
                CORE_TOOL_BASENAME="$CORE_TOOL_BASENAME $(basename "$item" -macos-x86_64.tar.xz)"
            fi
    esac
done

for item in hexdump date sort realpath base64 md5sum sha256sum
do
    run cp $TEMP_DIR/bin/$item "$OUTPUT_DIR/bin/"
done

CORE_TOOL_BASENAME=$(printf '%s\n' "$CORE_TOOL_BASENAME" | tr ' ' '\n')

UTILLINUX_BASENAME="$(basename util-linux-*.tar.xz    -macos-x86_64.tar.xz)"
COREUTILS_BASENAME="$(basename gnu-coreutils-*.tar.xz -macos-x86_64.tar.xz)"

cat > "$OUTPUT_DIR/README" <<EOF
release $OUTPUT_DIR

essential tools that are used by ppkg shell script.

$CORE_TOOL_BASENAME
$UTILLINUX_BASENAME/hexdump
$COREUTILS_BASENAME/date+sort+realpath+base64+md5sum+sha256sum

these tools are no any dependencies except libSystem.B.dylib.
these tools are relocatable which means that you can installed them anywhere.

following environment variables should be set for git:
export GIT_EXEC_PATH="\$PPKG_CORE_INSTALL_DIR/libexec/git-core"
export GIT_TEMPLATE_DIR="\$PPKG_CORE_INSTALL_DIR/share/git-core/templates"

following environment variables should be set for file:
export MAGIC="\$PPKG_CORE_INSTALL_DIR/share/misc/magic.mgc"
EOF

run rm "$OUTPUT_DIR/installed-metadata"
run rm "$OUTPUT_DIR/installed-files"

RELEASE_TARFILE="$OUTPUT_DIR.tar.xz"

run tar vcJf "$RELEASE_TARFILE" "$OUTPUT_DIR"

run mv "$RELEASE_TARFILE" "$OUTPUT_DIR"

run du -sh    "$OUTPUT_DIR/$RELEASE_TARFILE"

run sha256sum "$OUTPUT_DIR/$RELEASE_TARFILE"

run ls "$OUTPUT_DIR"

run gh release create "$RELEASE_VERSION" "$OUTPUT_DIR/$RELEASE_TARFILE" "$OUTPUT_DIR/bin/curl" "$OUTPUT_DIR/bin/tar" "$OUTPUT_DIR/bin/xz" *.tar.xz --notes-file "$OUTPUT_DIR/README"
