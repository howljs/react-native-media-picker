package com.reactnativemediapicker

import com.facebook.react.bridge.*
import com.luck.picture.lib.basic.PictureSelector
import com.luck.picture.lib.config.SelectMimeType
import com.luck.picture.lib.entity.LocalMedia
import com.luck.picture.lib.interfaces.OnResultCallbackListener


class MediaPickerModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return "MediaPicker"
    }

    @ReactMethod
    fun launchGallery(pickerOptions: ReadableMap?, promise: Promise) {
      PictureSelector.create(currentActivity)
        .openGallery(SelectMimeType.ofAll())
        .setImageEngine(GlideEngine.createGlideEngine())
        .forResult(object : OnResultCallbackListener<LocalMedia?> {
          override fun onResult(result: ArrayList<LocalMedia?>?) {
            promise.resolve("Data")
          }
          override fun onCancel() {}
        })
    }
}
