#!/usr/bin/env bash
# Checks the built APK without a device: package name, permissions, launcher and boot entry points,
# signature, and that the dashboard URL from config/dashboard.json is inside the app.
set -euo pipefail
cd "$(dirname "$0")"
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
BT=/opt/homebrew/share/android-commandlinetools/build-tools/30.0.3
APK=build/echoshow.apk
URL=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["url"])' ../config/dashboard.json)
fail=0

check() { # check <description> <command...>
  if "${@:2}" >/dev/null 2>&1; then echo "ok    $1"; else echo "FAIL  $1"; fail=1; fi
}

badging=$($BT/aapt dump badging "$APK")
xmltree=$($BT/aapt dump xmltree "$APK" AndroidManifest.xml)
check "package is com.ali.echoshow" grep -q "package: name='com.ali.echoshow'" <<<"$badging"
check "launcher activity present" grep -q "launchable-activity: name='com.ali.echoshow.MainActivity'" <<<"$badging"
check "landscape only" grep -q 'screenOrientation.*=.*1' <<<"$xmltree"
check "INTERNET permission" grep -q "android.permission.INTERNET" <<<"$badging"
check "RECORD_AUDIO permission (voice mode)" grep -q "android.permission.RECORD_AUDIO" <<<"$badging"
check "BOOT_COMPLETED receiver" grep -q "android.intent.action.BOOT_COMPLETED" <<<"$xmltree"
check "not a HOME app (device launcher untouched)" bash -c "! grep -q 'android.intent.category.HOME' <<<\"\$1\"" _ "$xmltree"
check "APK signature verifies" $BT/apksigner verify "$APK"
check "dashboard URL compiled in" bash -c "unzip -p '$APK' classes.dex | grep -aq -F '$URL'"

exit $fail
