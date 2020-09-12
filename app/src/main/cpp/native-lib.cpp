#include <jni.h>
#include <string>
#include <stdio.h>
#include <iostream>

#include <android/log.h>

#include "libusb/libusb/libusb.h"

extern "C" JNIEXPORT jstring JNICALL
Java_com_example_libusbtest_MainActivity_stringFromJNI(JNIEnv *env, jobject /* this */, int fd) {

    __android_log_print(ANDROID_LOG_INFO, "native", "Got fd from JVM: %d", fd);
    std::string hello = "Hello from C++";

    libusb_device **devs;
    int r;
    ssize_t cnt;

    r = libusb_init(NULL);
    if (r < 0) {
        __android_log_print(ANDROID_LOG_ERROR, "native", "Error: %d", r);
    }

    libusb_device_handle *handle = NULL;
    r = libusb_wrap_sys_device(NULL, (intptr_t)fd, &handle);
    if(r < 0) {
        __android_log_print(ANDROID_LOG_ERROR, "native", "Error wrapping meetup: %d", r);
    } else {
        __android_log_write(ANDROID_LOG_INFO, "native", "Have handle to meetup!");
        int iface = 1;
        int alt_setting = 0;
        r = libusb_set_interface_alt_setting(handle, iface, alt_setting);
        if (r < 0) {
            __android_log_print(ANDROID_LOG_ERROR, "native", "Error %d setting interface %d to alt setting %d", r, iface, alt_setting);
        }
        libusb_close(handle);
    }

    cnt = libusb_get_device_list(NULL, &devs);
    if (cnt < 0) {
        __android_log_print(ANDROID_LOG_ERROR, "native", "Error: %d", cnt);
        libusb_exit(NULL);
    } else {
        libusb_device *dev;
        int i = 0;

        __android_log_write(ANDROID_LOG_INFO, "native", "Devices:");
        while ((dev = devs[i++]) != NULL) {
            struct libusb_device_descriptor desc;
            int r = libusb_get_device_descriptor(dev, &desc);
            if (r < 0) {
                __android_log_print(ANDROID_LOG_ERROR, "native", "failed to get device descriptor");
            } else {
                __android_log_write(ANDROID_LOG_INFO, "native", "Found device!");
                if (desc.idVendor == 0x046d && desc.idProduct == 0x0866) {
                    __android_log_write(ANDROID_LOG_INFO, "native", "Found meetup!");
                    int ret = libusb_open(dev, &handle);
                    if (LIBUSB_SUCCESS == ret) {
                        __android_log_write(ANDROID_LOG_INFO, "native", "Opened meetup!");
                        libusb_close(handle);
                    } else {
                        __android_log_print(ANDROID_LOG_ERROR, "native", "Error opening meetup: %d", ret);
                    }
                }
            }
        }
        __android_log_print(ANDROID_LOG_INFO, "native", "Found %d devices!", cnt);
        libusb_free_device_list(devs, 1);
        libusb_exit(NULL);
    }

    return env->NewStringUTF(hello.c_str());
}

