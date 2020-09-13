# useful info
printenv
pwd
whoami

# updates
sudo apt-get -qq update -y
sudo apt-get -qq install -y linux-tools-$(uname -r) linux-modules-extra-$(uname -r) openjdk-8-jdk unzip wget curl git python python3 cmake build-essential pkg-config libusb-1.0-0-dev

# usbip
find /lib/modules/ -name usbip*
sudo modprobe usbip-core
sudo modprobe usbip-host
sudo modprobe vhci-hcd
git clone https://github.com/lcgamboa/USBIP-Virtual-USB-Device
cd USBIP-Virtual-USB-Device/c
make
./hid-mouse &
sudo usbip attach -r 127.0.0.1 -b 1-1
sudo ls -l /sys/bus/usb/devices/

echo "setup env"
export ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/${NDK_VERSION}
export TOOLCHAIN=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64
export PATH=${TOOLCHAIN}/bin:${ANDROID_HOME}/cmake/${CMAKE_VERSION}/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:$PATH

echo "Downloading and installing the Android SDK"
mkdir -p ~/.ssh/
mkdir -p /opt/
export DL_TARGET_SDK=/opt/android-sdk.zip
curl -sSf -o $DL_TARGET_SDK https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip
mkdir -p "$ANDROID_HOME"
unzip -q -d "$ANDROID_HOME" $DL_TARGET_SDK

echo "Configuring the SDK"
mkdir -p /root/.android
touch /root/.android/repositories.cfg
yes | sdkmanager --licenses > /dev/null
sdkmanager "tools" "platform-tools" "build-tools;${BUILD_TOOLS_VERSION}" "platforms;android-${TARGET_API}" > /dev/null
sdkmanager "cmake;${CMAKE_VERSION}" > /dev/null
sdkmanager "ndk;${NDK_VERSION}" > /dev/null

echo "Installing an emulator"
sdkmanager --list | grep system-images
sdkmanager --install "system-images;android-29;default;x86"
echo "no" | avdmanager --verbose create avd --force --name "generic_10" --package "system-images;android-29;default;x86" --tag "default" --abi "x86"

echo "Running emulator..."
emulator @generic_10 &
sleep 30