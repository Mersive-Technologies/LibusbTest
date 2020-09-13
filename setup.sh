# https://android.developreference.com/article/25508419/Connect+USB+device+to+Android+Emulator%3F
# https://www.qemu.org/docs/master/system/usb.html
# https://unix.stackexchange.com/questions/39370/how-to-reload-udev-rules-without-reboot/39371
# https://github.com/lcgamboa/USBIP-Virtual-USB-Device

echo "Hello world"
echo y | sdkmanager 'ndk-bundle'
echo y | sdkmanager 'cmake;3.6.4111459'
echo y | sdkmanager 'lldb;3.0'