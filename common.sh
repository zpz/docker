
function build-simple {
    BUILDDIR="$1"
    PARENT="$2"
    NAME="$(basename ${BUILDDIR})"

    VERSION="$(date -u +%Y%m%dT%H%M%SZ)"
    # UTC. This command with these arguments work the same on Mac and Linux.
    # Version format is like this:
    #    20180923T081243Z
    # which indicates full datetime accurate to seconds in UTC.
    # VERSION="$(date -u +%Y%m%d)"

    FULLNAME="${NAME}:${VERSION}"

    set -x
    docker build --build-arg PARENT="${PARENT}" -t "${FULLNAME}" "${BUILDDIR}" >&2
    set +x

    # set -x
    # docker tag ${FULLNAME} ${NAME}:latest
    # set +x
}
