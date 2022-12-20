package com.reactnativemediapicker

import com.facebook.react.bridge.*
import com.luck.picture.lib.basic.PictureSelector
import com.luck.picture.lib.config.FileSizeUnit
import com.luck.picture.lib.config.PictureConfig
import com.luck.picture.lib.config.SelectMimeType
import com.luck.picture.lib.entity.LocalMedia
import com.luck.picture.lib.interfaces.OnResultCallbackListener
import com.luck.picture.lib.language.LanguageConfig

class MediaPickerModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return "MediaPicker"
  }

  @ReactMethod
  fun launchGallery(pickerOptions: ReadableMap?, promise: Promise) {
    val options = PickerOptions(pickerOptions)
    val mimeType = when (options.assetType) {
      "video" -> SelectMimeType.ofVideo()
      "image" -> SelectMimeType.ofImage()
      else -> SelectMimeType.ofAll()
    }
    PictureSelector.create(currentActivity)
      .openGallery(mimeType)
      .setMaxSelectNum(options.limit ?: 0)
      .setImageSpanCount(options.numberOfColumn ?: PictureConfig.DEFAULT_SPAN_COUNT)
      .isPreviewImage(options.showPreview ?: false)
      .isPreviewVideo(options.showPreview ?: false)
      .setSelectMaxFileSize((options.maxFileSize ?: 0).toLong() * FileSizeUnit.KB)
      .setSelectMaxDurationSecond(options.maxDuration ?: 0)
      .isDisplayCamera(options.usedCameraButton ?: false)
      .setImageEngine(GlideEngine.createGlideEngine())
      .setLanguage(LanguageConfig.JAPAN)
      .forResult(object : OnResultCallbackListener<LocalMedia?> {
        override fun onResult(result: ArrayList<LocalMedia?>?) {
          val array = WritableNativeArray()
          result?.forEach { media ->
            if (media != null) {
              // Convert object to native map
              array.pushMap(media.toNativeMap())
            }
          }
          val response = WritableNativeMap()
          response.putArray("success", array)
          promise.resolve(response)
        }

        override fun onCancel() {}
      })
  }
}
