#!/usr/bin/env bash
#===============================================================================
#          FILE: kibana.sh
#
#         USAGE: ./kibana.sh
#
#   DESCRIPTION: Entrypoint for kibana docker container
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: David Personette (dperson@gmail.com),
#  ORGANIZATION:
#       CREATED: 2014-10-16 02:56
#      REVISION: 1.0
#===============================================================================

set -o nounset                              # Treat unset variables as an error

### timezone: Set the timezone for the container
# Arguments:
#   timezone) for example EST5EDT
# Return: the correct zoneinfo file will be symlinked into place
timezone() { local timezone="${1:-EST5EDT}"
    [[ -e /usr/share/zoneinfo/$timezone ]] || {
        echo "ERROR: invalid timezone specified: $timezone" >&2
        return
    }

    if [[ -w /etc/timezone && $(cat /etc/timezone) != $timezone ]]; then
        echo "$timezone" >/etc/timezone
        ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
        dpkg-reconfigure -f noninteractive tzdata >/dev/null 2>&1
    fi
}

### usage: Help
# Arguments:
#   none)
# Return: Help text
usage() { local RC=${1:-0}
    echo "Usage: ${0##*/} [-opt] [command]
Options (fields in '[]' are optional, '<>' are required):
    -h          This help
    -T \"\"       Configure timezone
                possible arg: \"[timezone]\" - zoneinfo timezone for container

The 'command' (if provided and valid) will be run instead of kibana
" >&2
    exit $RC
}

while getopts ":ht:" opt; do
    case "$opt" in
        h) usage ;;
        t) timezone "$OPTARG" ;;
        "?") echo "Unknown option: -$OPTARG"; usage 1 ;;
        ":") echo "No argument value for option: -$OPTARG"; usage 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

[[ "${TZ:-""}" ]] && timezone "$TZ"
[[ "${USERID:-""}" =~ ^[0-9]+$ ]] && usermod -u $USERID -o kibana
[[ "${GROUPID:-""}" =~ ^[0-9]+$ ]] && groupmod -g $GROUPID -o kibana

chown -Rh kibana. /opt/kibana 2>&1 | grep -iv 'Read-only' || :

if [[ $# -ge 1 && -x $(which $1 2>&-) ]]; then
    exec "$@"
elif [[ $# -ge 1 ]]; then
    echo "ERROR: command not found: $1"
    exit 13
elif ps -ef | egrep -v 'grep|kibana.sh' | grep -q kibana; then
    echo "Service already running, please restart container to apply changes"
else
    ELASTICSEARCH=${ELASTICSEARCH:-http://elasticsearch:9200}
    KIBANA_INDEX=${KIBANA_INDEX:-.kibana}
    DEFAULT_APP_ID=${DEFAULT_APP_ID:-discover}
    REQUEST_TIMEOUT=${REQUEST_TIMEOUT:-300000}
    SHARD_TIMEOUT=${SHARD_TIMEOUT:-0}
    VERIFY_SSL=${VERIFY_SSL:-true}

    sed -i "s|^\\(elasticsearch_url:\\).*|\\1 \"$ELASTICSEARCH\"|; \
                s|^\\(kibana_index:\\).*|\\1 \"$KIBANA_INDEX\"|; \
                s|^\\(default_app_id:\\).*|\\1 \"$DEFAULT_APP_ID\"|; \
                s|^\\(request_timeout:\\).*|\\1 $REQUEST_TIMEOUT|; \
                s|^\\(shard_timeout:\\).*|\\1 $SHARD_TIMEOUT|; \
                s|^\\(verify_ssl:\\).*|\\1 $VERIFY_SSL|;" \
                /opt/kibana/config/kibana.yml

    exec su -l kibana -s /bin/bash -c "exec /opt/kibana/bin/kibana"
fi