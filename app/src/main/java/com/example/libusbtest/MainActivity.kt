package com.example.libusbtest

import android.content.Context
import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbManager
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : AppCompatActivity() {
    private val tag: String = this.javaClass.name
    private var usbManager: UsbManager? = null
    private val devices = mutableMapOf<Int, UsbDeviceConnection>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        usbManager = getSystemService(Context.USB_SERVICE) as UsbManager
        for(dev in usbManager!!.deviceList.values) {
            Log.i(tag, "Found vid=${dev.vendorId} pid=${dev.productId}")
            if (dev.vendorId == 0x046d && dev.productId == 0x0866) {
                Log.i(tag, "Found meetup!")
                val con = usbManager!!.openDevice(dev)
                devices[dev.deviceId] = con
                Log.i(tag, "Opened meetup: fd=${con.fileDescriptor}")
            }
        }

        sample_text.text = stringFromJNI()
    }

    external fun stringFromJNI(): String

    companion object {
        // Used to load the 'native-lib' library on application startup.
        init {
            System.loadLibrary("native-lib")
        }
    }
}
