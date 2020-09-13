# https://android.developreference.com/article/25508419/Connect+USB+device+to+Android+Emulator%3F
# https://www.qemu.org/docs/master/system/usb.html
# https://unix.stackexchange.com/questions/39370/how-to-reload-udev-rules-without-reboot/39371
# https://github.com/lcgamboa/USBIP-Virtual-USB-Device

# useful info
set -x
printenv
pwd
whoami

export TARGET_API="25"
export BUILD_TOOLS_VERSION="30.0.1"
export NDK_VERSION="21.3.6528147"
export CMAKE_VERSION="3.10.2.4988404"
export DEBIAN_FRONTEND="noninteractive"
export ANDROID_HOME="$HOME/Android/Sdk"

# updates
sudo apt-get -qq remove -y openjdk*
sudo apt-get -qq update -y
sudo apt-get -qq install -y linux-tools-$(uname -r) linux-modules-extra-$(uname -r) openjdk-8-jdk \
  unzip wget curl git python python3 cmake build-essential pkg-config libusb-1.0-0-dev
java -version

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
mkdir -p $ANDROID_HOME
export ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/${NDK_VERSION}
export TOOLCHAIN=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64
export PATH=${ANDROID_HOME}/emulator:${TOOLCHAIN}/bin:${ANDROID_HOME}/cmake/${CMAKE_VERSION}/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:$PATH

echo "Downloading and installing the Android SDK"
mkdir -p $HOME/.ssh/
export DL_TARGET_SDK=$ANDROID_HOME/android-sdk.zip
curl -sSf -o $DL_TARGET_SDK https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
unzip -q -d "$ANDROID_HOME" $DL_TARGET_SDK

echo "Configuring the SDK"
mkdir -p $HOME/.android
touch $HOME/.android/repositories.cfg
yes | sdkmanager --licenses > /dev/null
sdkmanager "tools" "platform-tools" "build-tools;${BUILD_TOOLS_VERSION}" "platforms;android-${TARGET_API}" > /dev/null
sdkmanager "cmake;${CMAKE_VERSION}" > /dev/null
sdkmanager "ndk;${NDK_VERSION}" > /dev/null

echo "Installing an emulator"
sdkmanager --list | grep system-images
sdkmanager --install "system-images;android-29;default;x86"
echo "no" | avdmanager --verbose create avd --force --name "generic_10" --package "system-images;android-29;default;x86" --tag "default" --abi "x86"

ls -l /etc/udev/rules.d
echo 'KERNEL=="kvm", GROUP="kvm", MODE="0660"' | sudo tee -a /etc/udev/rules.d/50-udev-default.rules
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="2706", ATTR{idProduct}=="0000", MODE="1000", GROUP="plugdev"' | sudo tee -a /etc/udev/rules.d/20-custom.rules
sudo gpasswd -a $USER kvm
sudo udevadm control --reload-rules
sudo udevadm trigger
ls -l /dev/kvm
sudo chown -R $USER:$USER /dev/kvm

echo "Running emulator..."
echo ${ANDROID_HOME}
echo $PATH
ls -l ${ANDROID_HOME}
which emulator
emulator @generic_10 -no-window -qemu -usb -device usb-host,vendorid=2706,productid=0000 &
adb root
cat /sys/bus/usb/devices/**/idVendor
adb shell "cat /sys/bus/usb/devices/**/idVendor"
sleep 30
