package com.reactnativemediapicker

import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.WritableNativeMap
import com.luck.picture.lib.entity.LocalMedia

class PickerOptions(private val map: ReadableMap?) {
  val assetType: String? get() = map?.getString("assetType")
  val limit: Int? get() = map?.safeInt("limit")
  val numberOfColumn: Int? get() = map?.safeInt("numberOfColumn")
  val showPreview: Boolean? get() = map?.safeBoolean("showPreview")
  val maxFileSize: Int? get() = map?.safeInt("maxFileSize")
  val maxDuration: Int? get() = map?.safeInt("maxDuration")
  val usedCameraButton: Boolean? get() = map?.safeBoolean("usedCameraButton")

  val messages: MessageOptions? get() = map?.let { MessageOptions(it) }
  @Deprecated("unused")
  val maxVideoDuration: Int? get() = map?.safeInt("maxVideoDuration")
  @Deprecated("unused")
  val maxOriginalSize: Int? get() = map?.safeInt("maxOriginalSize")
  @Deprecated("iOS only")
  val writeTempFile: Boolean? get() = map?.safeBoolean("writeTempFile")
}

class MessageOptions(private val map: ReadableMap) {
  val fileTooLarge: String? get() = map.getString("fileTooLarge")
  val noCameraPermissions: String? get() = map.getString("noCameraPermissions")
  val noAlbumPermission: String? get() = map.getString("noAlbumPermission")
  val maxSelection: String? get() = map.getString("maxSelection")
  val ok: String? get() = map.getString("ok")
  val maxDuration: String? get() = map.getString("maxDuration")
  val tapHereToChange: String? get() = map.getString("tapHereToChange")
  val cancelTitle: String? get() = map.getString("cancelTitle")
  val emptyMessage: String? get() = map.getString("emptyMessage")
  val doneTitle: String? get() = map.getString("doneTitle")
}

fun ReadableMap.safeInt(key: String): Int? {
  if (!hasKey(key) || isNull(key)) {
    return null
  }
  return getInt(key)
}

fun ReadableMap.safeBoolean(key: String): Boolean? {
  if (!hasKey(key) || isNull(key)) {
    return null
  }
  return getBoolean(key)
}

fun LocalMedia.toNativeMap(): WritableMap {
  return WritableNativeMap().apply {
    putString("uri", path)
    putString("path", path)
    putDouble("size", size.toDouble())
    putString("name", fileName)
    putString("type", mimeType)
    putInt("width", width)
    putInt("height", height)
    putDouble("duration", duration.toDouble())
    putString("origUrl", originalPath)
    putString("mimeType", mimeType)
  }
}
