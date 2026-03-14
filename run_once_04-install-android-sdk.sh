#!/bin/bash
set -euo pipefail

# Android development toolchain: JDK 17, Android SDK, adb

# JDK 17
if ! java -version 2>&1 | grep -q '"17\.'; then
    echo "==> Installing JDK 17..."
    sudo apt-get update
    sudo apt-get install -y openjdk-17-jdk
fi

# adb (Android Debug Bridge)
if ! command -v adb &>/dev/null; then
    echo "==> Installing adb..."
    sudo apt-get update
    sudo apt-get install -y adb
fi

# Android SDK command-line tools
ANDROID_HOME="$HOME/Android/Sdk"
CMDLINE_TOOLS_DIR="$ANDROID_HOME/cmdline-tools/latest"
if [ ! -d "$CMDLINE_TOOLS_DIR" ]; then
    echo "==> Installing Android SDK command-line tools..."
    mkdir -p "$ANDROID_HOME/cmdline-tools"
    CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
    curl -fsSL "$CMDLINE_TOOLS_URL" -o /tmp/cmdline-tools.zip
    unzip -qo /tmp/cmdline-tools.zip -d /tmp/cmdline-tools-tmp
    mv /tmp/cmdline-tools-tmp/cmdline-tools "$CMDLINE_TOOLS_DIR"
    rm -rf /tmp/cmdline-tools.zip /tmp/cmdline-tools-tmp
fi

# Accept licenses and install SDK components
SDKMANAGER="$CMDLINE_TOOLS_DIR/bin/sdkmanager"
if [ -x "$SDKMANAGER" ]; then
    echo "==> Installing Android SDK components..."
    yes | "$SDKMANAGER" --licenses > /dev/null 2>&1 || true
    "$SDKMANAGER" --install \
        "platforms;android-35" \
        "build-tools;35.0.0" \
        "platform-tools"
fi

echo "==> Android SDK setup done!"
echo "    Make sure ANDROID_HOME and JAVA_HOME are set in your shell profile."
