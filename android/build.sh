#!/usr/bin/env bash
# Builds build/echoshow.apk with the Android SDK command-line tools (no Gradle).
# The dashboard URL comes from ../config/dashboard.json and is compiled into the app.
set -euo pipefail
cd "$(dirname "$0")"
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
SDK=/opt/homebrew/share/android-commandlinetools
BT=$SDK/build-tools/30.0.3
JAR=$SDK/platforms/android-22/android.jar
PKG=com.ali.echoshow
rm -rf build && mkdir -p build/gen build/classes build/dex

URL=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["url"])' ../config/dashboard.json)
mkdir -p build/gen/com/ali/echoshow
cat > build/gen/com/ali/echoshow/Config.java <<EOF
package com.ali.echoshow;

final class Config {
    static final String DASHBOARD_URL = "$URL";
}
EOF

$BT/aapt2 link -o build/base.apk -I "$JAR" --manifest AndroidManifest.xml \
  --min-sdk-version 22 --target-sdk-version 22
$JAVA_HOME/bin/javac -source 8 -target 8 -Xlint:-options -bootclasspath "$JAR" \
  -d build/classes src/com/ali/echoshow/*.java build/gen/com/ali/echoshow/Config.java
$BT/d8 --lib "$JAR" --min-api 22 --output build/dex $(find build/classes -name '*.class')
cp build/base.apk build/unaligned.apk
(cd build/dex && zip -q ../unaligned.apk classes.dex)

# Debug-signed with a key generated on this Mac. It stays in build/ and is never committed.
[ -f build/debug.keystore ] || $JAVA_HOME/bin/keytool -genkeypair -keystore build/debug.keystore \
  -storepass android -keypass android -alias echoshow -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=Echo Show Family OS" >/dev/null 2>&1
$BT/zipalign -f 4 build/unaligned.apk build/aligned.apk
$BT/apksigner sign --ks build/debug.keystore --ks-pass pass:android --out build/echoshow.apk build/aligned.apk
echo "Built build/echoshow.apk for $URL"
