#!/usr/bin/env bash
# Read-only check of one device's debug interfaces: ADB over Wi-Fi (5555), HTTP (80) and the command centre URL.
# Usage: device/probe.sh <ip>
set -u
ip=${1:?usage: device/probe.sh <ip>}

check() {
  if nc -z -G 2 "$ip" "$1" 2>/dev/null; then echo "open    $ip:$1 $2"; else echo "closed  $ip:$1 $2"; fi
}

check 5555 "ADB over Wi-Fi"
check 80 "HTTP"

if adb devices | grep -q "^$ip:5555[[:space:]]*device"; then
  echo "adb     connected: $(adb -s "$ip:5555" shell getprop ro.product.model </dev/null | tr -d '\r')"
else
  echo "adb     not connected (run 'adb connect $ip:5555' only after the device's developer access is confirmed)"
fi
