#!/usr/bin/env bash
#
# headers-checker.sh
# Version: 1.0.0
# Author: CyberGuardians
# Description: Secure HTTP header scanner with color-coded output, JSON export, and safe curl handling.
# License: MIT
#

set -euo pipefail

VERSION="1.0.0"

# ====== COLORS ======
RED=$(tput setaf 1 || echo "")
GREEN=$(tput setaf 2 || echo "")
YELLOW=$(tput setaf 3 || echo "")
BLUE=$(tput setaf 4 || echo "")
RESET=$(tput sgr0 || echo "")

# ====== GLOBALS ======
NON_INTERACTIVE=false
INSECURE=false
JSON_OUTPUT=""
URL=""

# ====== SAFE CURL WRAPPER ======
safe_curl() {
    local url="$1"; shift
    local response

    response=$(curl -sSL -w "HTTP_CODE:%{http_code}" -o /tmp/hc_body.txt \
        "${@}" "$url" 2>/tmp/hc_error.txt || true)

    if grep -q "HTTP_CODE:" <<<"$response"; then
        echo "$response"
        return 0
    else
        echo "Error: $(cat /tmp/hc_error.txt)"
        return 1
    fi
}

# ====== URL VALIDATION ======
validate_url() {
    local url="$1"
    if [[ ! "$url" =~ ^https?://[a-zA-Z0-9._-]+ ]]; then
        echo "${RED}Invalid URL format${RESET}"
        return 1
    fi
}

check_https() {
    local url="$1"
    if [[ ! "$url" =~ ^https:// ]]; then
        read -p "${YELLOW}Warning: Non-HTTPS URL. Continue? (y/n): ${RESET}" answer
        [[ "$answer" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 4; }
    fi
}

# ====== HEADER SCAN ======
scan_headers() {
    local url="$1"
    echo "${BLUE}[*] Scanning headers for:${RESET} $url"
    echo

    response=$(curl -s -I -L ${INSECURE:+--insecure} "$url" || true)

    if [ -z "$response" ]; then
        echo "${RED}No response received.${RESET}"
        return 2
    fi

    echo "$response" | while IFS= read -r line; do
        case "$line" in
            *Strict-Transport-Security*) echo "${GREEN}$line${RESET}" ;;
            *Content-Security-Policy*) echo "${GREEN}$line${RESET}" ;;
            *X-Frame-Options*) echo "${GREEN}$line${RESET}" ;;
            *X-Content-Type-Options*) echo "${GREEN}$line${RESET}" ;;
            *Referrer-Policy*) echo "${GREEN}$line${RESET}" ;;
            *) echo "  $line" ;;
        esac
    done

    if [ -n "$JSON_OUTPUT" ]; then
        echo "$response" | jq -R -s '{"headers": split("\n")}' > "$JSON_OUTPUT"
        echo "${YELLOW}JSON results saved to:${RESET} $JSON_OUTPUT"
    fi
}

# ====== ARGUMENT PARSER ======
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --json-out)
                JSON_OUTPUT="$2"; shift 2;;
            --insecure)
                INSECURE=true; shift;;
            --non-interactive)
                NON_INTERACTIVE=true; shift;;
            -h|--help)
                show_help; exit 0;;
            -v|--version)
                echo "headers-checker v$VERSION"; exit 0;;
            http*://*)
                URL="$1"; shift;;
            *)
                echo "${RED}Unknown option:$1${RESET}"; exit 1;;
        esac
    done
}

show_help() {
    cat <<EOF
Usage: $0 [options] <url>

Options:
  --json-out <file>     Save output in JSON format
  --insecure            Skip SSL certificate verification
  --non-interactive     Skip user prompts (CI/CD mode)
  -h, --help            Show this help menu
  -v, --version         Show version information

Examples:
  $0 https://example.com
  $0 --json-out results.json https://example.com
  $0 --non-interactive --insecure https://test.local
EOF
}

# ====== MAIN ======
main() {
    parse_arguments "$@"
    [[ -z "$URL" ]] && { echo "${RED}Error: URL required${RESET}"; show_help; exit 1; }

    validate_url "$URL" || exit 3
    [[ "$NON_INTERACTIVE" = false ]] && check_https "$URL"
    scan_headers "$URL"
    echo
    echo "${GREEN}Scan completed successfully!${RESET}"
}

# ====== EXECUTION GUARD ======
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
