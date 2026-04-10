#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

log_file="$(mktemp /tmp/bb-smoke.XXXXXX.log)"
trap 'rm -f "$log_file"' EXIT

make all >/dev/null

set +e
{
  sleep 1
  printf 'uname\n'
  printf 'help\n'
  printf 'man ping\n'
  printf 'ls /bin\n'
  printf 'cat /bin/ping\n'
  printf 'cat /bin/ring3demo\n'
  printf 'cat /proc/tasks\n'
  printf 'cat /proc/aspace\n'
  printf 'mouse status\n'
  printf 'open /net/stats r\n'
  printf 'readfd 0\n'
  printf 'close 0\n'
  printf 'run /bin/netstat\n'
  printf 'run /bin/ping loopback 1\n'
  printf 'run /bin/ring3demo\n'
  printf 'netstat\n'
  printf 'ping loopback 1\n'
  printf 'trace start\n'
  printf 'net send smoke-packet\n'
  printf 'trace stop\n'
  printf 'cat /trace/index\n'
  printf 'cat /trace/session-1.meta\n'
  printf 'posix status\n'
} | timeout 30s make run >"$log_file" 2>&1
run_rc=$?
set -e
if [[ "$run_rc" != "0" && "$run_rc" != "124" ]]; then
  cat "$log_file"
  echo "smoke test failed: qemu run failed"
  exit 1
fi

expect() {
  local pattern="$1"
  if ! grep -Fq "$pattern" "$log_file"; then
    cat "$log_file"
    echo "smoke test failed: missing pattern: $pattern"
    exit 1
  fi
}

expect "BB kernel booted"
expect "help, man, ls, cat, write, open"
expect "NAME"
expect "ping - send ICMP-like loopback traffic through /net"
expect "executables:"
expect "/bin/ping"
expect "path=/bin/ping"
expect "path=/bin/ring3demo"
expect "pid ppid aspace state"
expect "id kind refs isolated cr3 ustack label"
expect "mouse present="
expect "tx_packets="
expect "netstat tx="
expect "ping summary target=loopback sent=1 recv=1 loss=0%"
expect "run /bin/ping loopback 1"
expect "ring3 file-backed elf says hello"
expect "run /bin/ring3demo => rc=0"
expect "trace recording enabled"
expect "trace recording stopped"
expect "trace sessions"
expect "session=1"
expect "vfs namespaces: /trace /bin /net /proc exposed through fd-backed reads/writes"

echo "smoke test passed"
