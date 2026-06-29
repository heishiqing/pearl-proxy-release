#!/usr/bin/env bash
set -euo pipefail

APP_NAME="pearl-proxy"
BIN_NAME="pearl-proxy-linux-amd64"
SERVICE_NAME="pearl-proxy"

INSTALL_DIR="/opt/pearl-proxy"
BINARY_PATH=""
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: ./install-linux.sh [options]

Interactive first-time Linux installer for pearl-proxy.

The installer only asks for the admin/dashboard bootstrap settings. Pool,
wallet, fee, and P-pool opaque-login settings can be changed later in the web
dashboard or by editing config.json on the server.

Options:
  --install-dir DIR   Install directory, default: /opt/pearl-proxy
  --binary PATH       Path to pearl-proxy-linux-amd64
  --dry-run           Generate output preview without writing system files
  -h, --help          Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --install-dir)
      INSTALL_DIR="${2:-}"
      shift 2
      ;;
    --binary)
      BINARY_PATH="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This installer is intended for Linux." >&2
  exit 2
fi

if [[ -z "$BINARY_PATH" ]]; then
  if [[ -x "./$BIN_NAME" ]]; then
    BINARY_PATH="./$BIN_NAME"
  elif [[ -f "./$BIN_NAME" ]]; then
    BINARY_PATH="./$BIN_NAME"
  else
    BINARY_PATH="$BIN_NAME"
  fi
fi

prompt_default() {
  local label="$1"
  local default="$2"
  local value
  read -r -p "$label [$default]: " value
  printf '%s' "${value:-$default}"
}

prompt_required() {
  local label="$1"
  local value
  while true; do
    read -r -p "$label: " value
    if [[ -n "$value" ]]; then
      printf '%s' "$value"
      return
    fi
    echo "Required."
  done
}

prompt_secret_default() {
  local label="$1"
  local default="$2"
  local value
  read -r -s -p "$label [press Enter to use generated]: " value
  echo
  printf '%s' "${value:-$default}"
}

yes_no() {
  local label="$1"
  local default="$2"
  local value
  local hint="[y/N]"
  [[ "$default" == "y" ]] && hint="[Y/n]"
  while true; do
    read -r -p "$label $hint: " value
    value="${value:-$default}"
    case "${value,,}" in
      y|yes) return 0 ;;
      n|no) return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

random_password() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -base64 24 | tr -d '\n'
  else
    date +%s%N | sha256sum | awk '{print $1}'
  fi
}

validate_port() {
  local value="$1"
  [[ "$value" =~ ^[0-9]+$ ]] || return 1
  (( value >= 1 && value <= 65535 ))
}

json_escape() {
  sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

run_root() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "+ $*"
    return 0
  fi
  if [[ "$EUID" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

write_root_file() {
  local src="$1"
  local dst="$2"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "+ install file $src -> $dst"
    return 0
  fi
  if [[ "$EUID" -eq 0 ]]; then
    install -m 0644 "$src" "$dst"
  else
    sudo install -m 0644 "$src" "$dst"
  fi
}

echo "== pearl-proxy first-time installer =="
echo

INSTALL_DIR="$(prompt_default "Install directory" "$INSTALL_DIR")"
DASH_HOST="$(prompt_default "Dashboard bind host" "0.0.0.0")"
DASH_PORT="$(prompt_default "Dashboard port" "8080")"
while ! validate_port "$DASH_PORT"; do
  echo "Invalid port. Use 1-65535."
  DASH_PORT="$(prompt_default "Dashboard port" "8080")"
done

DASH_USER="$(prompt_default "Dashboard admin user" "admin")"
DASH_PASS="$(prompt_secret_default "Dashboard admin password" "$(random_password)")"

ENABLE_SYSTEMD=0
if yes_no "Install and start systemd service" "y"; then
  ENABLE_SYSTEMD=1
fi

if [[ ! -f "$BINARY_PATH" ]]; then
  echo "Binary not found: $BINARY_PATH" >&2
  echo "Put $BIN_NAME next to this installer, or pass --binary /path/to/$BIN_NAME." >&2
  exit 2
fi

if [[ "$DRY_RUN" -ne 1 && -f "$INSTALL_DIR/config.json" ]]; then
  if ! yes_no "$INSTALL_DIR/config.json already exists. Overwrite" "n"; then
    echo "Aborted."
    exit 1
  fi
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

esc_user="$(printf '%s' "$DASH_USER" | json_escape)"
esc_pass="$(printf '%s' "$DASH_PASS" | json_escape)"
dashboard_listen="$DASH_HOST:$DASH_PORT"

cat > "$tmp_dir/config.json" <<EOF
{
  "pools": [
    {
      "name": "srb-luckypool-sg",
      "listen": "0.0.0.0:19360",
      "upstream": "pearl-sg1.luckypool.io:3360",
      "protocol": "generic",
      "tls": false
    },
    {
      "name": "srb-herominers-hk",
      "listen": "0.0.0.0:19361",
      "upstream": "hk.herominers.com:1200",
      "protocol": "generic",
      "tls": false
    },
    {
      "name": "srb-kryptex-hk",
      "listen": "0.0.0.0:19362",
      "upstream": "prl-hk.kryptex.network:7048",
      "protocol": "generic",
      "tls": false
    },
    {
      "name": "srb-2miners",
      "listen": "0.0.0.0:19363",
      "upstream": "asia-prl.2miners.com:1818",
      "protocol": "generic",
      "tls": false
    },
    {
      "name": "tw-pearlfortune-jp",
      "listen": "0.0.0.0:19364",
      "upstream": "jp.pearlfortune.org:8888",
      "protocol": "generic",
      "tls": true,
      "tls_insecure_skip_verify": true
    },
    {
      "name": "alphapool-sg",
      "listen": "0.0.0.0:19365",
      "upstream": "sg1.alphapool.tech:5566",
      "protocol": "alphapool",
      "tls": false
    },
    {
      "name": "wildrig-pearlhash",
      "listen": "0.0.0.0:19366",
      "upstream": "pool.pearlhash.xyz:9000",
      "protocol": "wildrig-pearlhash-opaque",
      "tls": false,
      "opaque_operator_login_b64": "REPLACE_WITH_WILDRIG_OPERATOR_LOGIN_FRAME_BASE64",
      "opaque_dev_login_b64": "REPLACE_WITH_WILDRIG_DEV_LOGIN_FRAME_BASE64",
      "opaque_switch_seconds": 60
    }
  ],
  "operator": {
    "wallet": "",
    "fee_percent": 0
  },
  "dashboard": {
    "listen": "$dashboard_listen",
    "user": "$esc_user",
    "password": "$esc_pass"
  }
}
EOF

cat > "$tmp_dir/$SERVICE_NAME.service" <<EOF
[Unit]
Description=pearl-proxy PRL mining relay
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/$BIN_NAME -config $INSTALL_DIR/config.json
Restart=always
RestartSec=5
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

echo
echo "== Install summary =="
echo "Install dir:        $INSTALL_DIR"
echo "Binary:             $BINARY_PATH"
echo "Dashboard:          http://<server-ip>:$DASH_PORT"
echo "Dashboard listen:   $dashboard_listen"
echo "Dashboard user:     $DASH_USER"
echo "Operator wallet:    set later in dashboard or config.json"
echo "Operator fee:       set later in dashboard or config.json"
echo "Pool ports:         default 19360-19366, editable later"
echo "Systemd service:    $([[ "$ENABLE_SYSTEMD" -eq 1 ]] && echo yes || echo no)"
echo

if ! yes_no "Proceed with install" "y"; then
  echo "Aborted."
  exit 1
fi

run_root install -d -m 0755 "$INSTALL_DIR"
run_root install -m 0755 "$BINARY_PATH" "$INSTALL_DIR/$BIN_NAME"
write_root_file "$tmp_dir/config.json" "$INSTALL_DIR/config.json"

if [[ "$ENABLE_SYSTEMD" -eq 1 ]]; then
  write_root_file "$tmp_dir/$SERVICE_NAME.service" "/etc/systemd/system/$SERVICE_NAME.service"
  run_root systemctl daemon-reload
  run_root systemctl enable "$SERVICE_NAME.service"
  run_root systemctl restart "$SERVICE_NAME.service"
fi

echo
echo "== Done =="
echo "Config: $INSTALL_DIR/config.json"
echo "Dashboard: http://<server-ip>:$DASH_PORT"
echo "Login: $DASH_USER / <password set during install>"
echo
echo "Pool ports:"
echo "  LuckyPool:     19360"
echo "  HeroMiners:    19361"
echo "  Kryptex:       19362"
echo "  2Miners:       19363"
echo "  PearlFortune:  19364"
echo "  AlphaPool:     19365"
echo "  P pool:        19366"
echo

echo "Next setup:"
echo "  Open the dashboard and set operator wallet, fee, pool ports, and any upstream changes."
echo "  Or edit $INSTALL_DIR/config.json on the server, then restart pearl-proxy."
echo

if [[ "$ENABLE_SYSTEMD" -eq 1 ]]; then
  echo "Service commands:"
  echo "  systemctl status $SERVICE_NAME"
  echo "  journalctl -u $SERVICE_NAME -f"
else
  echo "Manual start:"
  echo "  cd $INSTALL_DIR && ./$BIN_NAME -config config.json"
fi

cat <<EOF

P-pool note:
  The generated P-pool config contains placeholder opaque login frames.
  Before using the P-pool port, capture operator/dev frames with:

  ./opaque-login-capture -listen 127.0.0.1:19470 -role operator -config $INSTALL_DIR/config.json -pool wildrig-pearlhash
  ./opaque-login-capture -listen 127.0.0.1:19471 -role dev      -config $INSTALL_DIR/config.json -pool wildrig-pearlhash
EOF
