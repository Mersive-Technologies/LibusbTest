#include <jni.h>
#include <string>
#include <stdio.h>
#include <iostream>

#include <android/log.h>

#include "libusb/libusb/libusb.h"

extern "C" JNIEXPORT jstring JNICALL
Java_com_example_libusbtest_MainActivity_stringFromJNI(JNIEnv *env, jobject /* this */) {
    std::string hello = "Hello from C++";

    libusb_device **devs;
    int r;
    ssize_t cnt;

    r = libusb_init(NULL);
    if (r < 0) {
        __android_log_print(ANDROID_LOG_ERROR, "native", "Error: %d", r);
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
                }
            }
        }
        __android_log_print(ANDROID_LOG_ERROR, "native", "Error: %d", cnt);
        libusb_free_device_list(devs, 1);
        libusb_exit(NULL);
    }

    return env->NewStringUTF(hello.c_str());
}

