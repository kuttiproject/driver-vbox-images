#!/bin/bash
set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] PROXYADDRESS [NOPROXYADDRESSES]

Options:
  -r    Removes proxy settings. No need to specify further parameters.
  -h    Shows this help message.

Notes:
EOF
    if [[ $EUID -ne 0 ]]; then
        echo "  * MUST be run with root privileges."
    fi
    cat <<EOF
  * PROXYADDRESS should include the protocol and port number. E.g. http://proxy:8080
  * NOPROXYADDRESSES should be comma-separated, without spaces. E.g. 192.168.125.4,192.168.125.5
    If not specified, a set of sequential IP addresses will be generated automatically.
    The range can be controlled using environment variables, as follows:
    \$NETPREFIX.\$IPSTART through \$NETPREFIX.\$IPEND
    The default range is 192.168.125.10 through 192.168.125.20

EOF
}

generate_no_proxy() {
    local netprefix="${NETPREFIX:-192.168.125}"
    local ipstart="${IPSTART:-10}"
    local ipend="${IPEND:-20}"
    local ips=()

    for ((i=ipstart; i<=ipend; i++)); do
        ips+=("${netprefix}.${i}")
    done

    # Join array with commas
    local IFS=,
    echo "${ips[*]}"
}

valid_proxy_format() {
    local rex='^https?://[^/:]+(:[0-9]{1,5})?/?$'
    [[ "$1" =~ $rex ]]
}

# Fast-pass help check
if [[ $# -eq 0 ]] || [[ "${1:-}" == "-h" ]]; then
    usage
    exit 0
fi

# Ensure root privilege ($EUID is a built-in Bash variable)
if [[ $EUID -ne 0 ]]; then
    echo "Error: $0 must be run as root. Use sudo." >&2
    exit 1
fi

# Handle removal flag
if [[ "$1" == "-r" ]]; then
    echo "Removing user proxy..."
    rm -f /etc/profile.d/kutti-proxy.sh

    echo "Removing daemon proxy..."
    rm -f /etc/systemd/system.conf.d/kutti-proxy.conf

    echo "Restarting daemons..."
    systemctl daemon-reload
    for svc in containerd kubelet; do
        if systemctl is-active --quiet "$svc" || systemctl is-enabled --quiet "$svc"; then
            systemctl restart "$svc" || echo "Warning: Failed to restart $svc" >&2
        fi
    done

    echo "Proxy configuration files removed. Open new shell sessions for changes to take effect."
    exit 0
fi

PROXYADDRESS="$1"

if ! valid_proxy_format "$PROXYADDRESS"; then
    echo "Error: Invalid proxy format '$PROXYADDRESS'." >&2
    echo "Expected format: http[s]://HOST[:PORT]" >&2
    exit 1
fi

NOPROXYADDRESSES="${2:-$(generate_no_proxy)}"
PROFILE_FILE="/etc/profile.d/kutti-proxy.sh"
SYSTEMD_CONF_DIR="/etc/systemd/system.conf.d"
SYSTEMD_CONF_FILE="${SYSTEMD_CONF_DIR}/kutti-proxy.conf"

echo "Setting up user proxy..."

# Overwrite (>) file to prevent accumulating duplicates
cat <<EOF > "$PROFILE_FILE"
export http_proxy="${PROXYADDRESS}"
export https_proxy="${PROXYADDRESS}"
export HTTP_PROXY="${PROXYADDRESS}"
export HTTPS_PROXY="${PROXYADDRESS}"
export no_proxy="127.0.0.1,localhost,${NOPROXYADDRESSES}"
export NO_PROXY="127.0.0.1,localhost,${NOPROXYADDRESSES}"
EOF

chmod 644 "$PROFILE_FILE"

echo "Setting up daemon proxy..."
mkdir -p "$SYSTEMD_CONF_DIR"

# Overwrite (>) file with single-line space-delimited DefaultEnvironment
cat <<EOF > "$SYSTEMD_CONF_FILE"
[Manager]
DefaultEnvironment="http_proxy=${PROXYADDRESS}" "https_proxy=${PROXYADDRESS}" "no_proxy=127.0.0.1,localhost,${NOPROXYADDRESSES}" "HTTP_PROXY=${PROXYADDRESS}" "HTTPS_PROXY=${PROXYADDRESS}" "NO_PROXY=127.0.0.1,localhost,${NOPROXYADDRESSES}"
EOF

echo "Restarting daemons..."
systemctl daemon-reload

for svc in containerd kubelet; do
    if systemctl is-active --quiet "$svc" || systemctl is-enabled --quiet "$svc"; then
        systemctl restart "$svc" || echo "Warning: Failed to restart $svc" >&2
    fi
done

echo "Done. Proxy configured successfully."
echo "Note: Re-login or source /etc/profile.d/kutti-proxy.sh to apply environment changes to current shell."
