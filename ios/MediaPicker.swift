@objc(MediaPicker)
class MediaPicker: NSObject, TLPhotosPickerViewControllerDelegate {
  var viewController: TLPhotosPickerViewController? = nil
  var resolve: RCTPromiseResolveBlock? = nil
  var reject: RCTPromiseRejectBlock? = nil
  var options: [String: Any]? = nil
  
  @objc(exportVideoFromId:withResolver:withRejecter:)
    func exportVideoFromId(arguments: NSDictionary?, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if let localIdentifier = arguments?["localIdentifier"] as? String {
            let tlPHAsset: TLPHAsset? = TLPHAsset.asset(with: localIdentifier)
            if tlPHAsset?.type == TLPHAsset.AssetType.video {
                let phVideoOptions = PHVideoRequestOptions()
                let videoType = AVFileType.mp4
                phVideoOptions.isNetworkAccessAllowed = true
                tlPHAsset?.exportVideoFile(options: phVideoOptions,
                                           outputURL: nil,
                                           outputFileType: videoType,
                                           progressBlock: nil,
                                           completionBlock: {(url, mimeType) in
                                            var media = [String: Any]()
                                            media["name"] = tlPHAsset?.originalFileName!
                                            media["width"] = tlPHAsset?.phAsset!.pixelWidth
                                            media["height"] = tlPHAsset?.phAsset!.pixelHeight
                                            media["uri"] = url.absoluteString
                                            media["mimeType"] = mimeType
                                            resolve(media)
                                           })
            } else {
                let error = NSError(domain: "", code: -2, userInfo: nil)
                reject("ERROR_FOUND", "File not supported", error)
            }
        } else {
            let error = NSError(domain: "", code: -1, userInfo: nil)
            reject("ERROR_FOUND", "localIdentifier is require", error)
        }
    }
    
    @objc(launchGallery:withResolver:withRejecter:)
    func launchGallery(arguments: [String: Any]?, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        var configure = TLPhotosPickerConfigure()
        self.options = arguments
        let assetType = arguments?["assetType"] as? String ?? "image"
        let limit = arguments?["limit"] as? Int ?? 1
        let numberOfColumn = arguments?["numberOfColumn"] as? Int ?? 3
        if assetType == "image" {
            configure.mediaType = PHAssetMediaType.image
        } else if assetType == "video" {
            configure.mediaType = PHAssetMediaType.video
        }
        
        if let messages = arguments?["messages"] as? NSDictionary {
            if let tapHereToChange = messages["tapHereToChange"] as? String {
                configure.tapHereToChange = tapHereToChange
            }
            if let cancelTitle = messages["cancelTitle"] as? String {
                configure.cancelTitle = cancelTitle
            }
            if let doneTitle = messages["doneTitle"] as? String {
                configure.doneTitle = doneTitle
            }
            if let emptyMessage = messages["emptyMessage"] as? String {
                configure.emptyMessage = emptyMessage
            }
        }
        
        if let maxVideoDuration = arguments!["maxVideoDuration"] as? Double {
            configure.maxVideoDuration = maxVideoDuration
        }
        configure.usedCameraButton = arguments?["usedCameraButton"] as? Bool ?? false
        configure.recordingVideoQuality = .typeHigh
        configure.singleSelectedMode = limit < 2
        configure.maxSelectedAssets = limit
        configure.numberOfColumn = numberOfColumn
        configure.autoPlay = false
        DispatchQueue.main.async {
            self.resolve = resolve
            self.reject = reject
            let rootController = self.topMostViewController()
            self.viewController = TLPhotosPickerViewController()
            self.viewController?.delegate = self
            self.viewController?.configure = configure
            rootController?.present(self.viewController!, animated: true, completion: nil)
        }
    }
    
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        DispatchQueue.global().async {
            var medias: Array<[String: Any]> = Array<[String: Any]>()
            for asset in withTLPHAssets {
                let semaphore = DispatchSemaphore(value: 0)
                var media = [String: Any]()
                media["name"] = asset.originalFileName!
                media["width"] = asset.phAsset!.pixelWidth
                media["height"] = asset.phAsset!.pixelHeight
                media["uri"] = "ph://\(asset.phAsset!.localIdentifier)"
                if asset.type == .photo {
                    media["type"] = "image"
                    asset.photoSize(completion: {(fileSize) in
                        media["size"] = fileSize
                        if self.options?["writeTempFile"] as? Bool == true {
                            asset.tempCopyMediaFile(
                                videoRequestOptions: nil,
                                imageRequestOptions: nil,
                                livePhotoRequestOptions: nil,
                                exportPreset: AVAssetExportPresetHighestQuality,
                                convertLivePhotosToJPG: true,
                                progressBlock: { (progress) in
                                    print(progress)
                                },
                                completionBlock: { (url, mimeType) in
                                    media["origUrl"] = url.absoluteString
                                    media["mimeType"] = mimeType
                                    medias.append(media)
                                    semaphore.signal()
                                }
                            )
                        } else {
                            medias.append(media)
                            semaphore.signal()
                        }
                        
                    })
                } else if asset.type == .video {
                    media["type"] = "video"
                    media["duration"] = asset.phAsset!.duration
                    asset.videoSize(completion: {(fileSize) in
                        media["size"] = fileSize
                        medias.append(media)
                        semaphore.signal()
                    })
                } else {
                    medias.append(media)
                    semaphore.signal()
                }
                _ = semaphore.wait(timeout: .distantFuture)
            }
            DispatchQueue.main.async {
                var response = [String: Any]()
                response["success"] = medias
                response["error"] = 0
                self.resolve!(response)
                self.resolve = nil
            }
        }
    }
    
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        // if you want to used phasset.
    }
    
    func photoPickerDidCancel() {}
    func dismissComplete() {}
    func canSelectAsset(phAsset: PHAsset) -> Bool {
        var isValid: Bool = true
        if let maxSize = self.options!["maxFileSize"] as? Float {
            let imageRequestOptions = PHImageRequestOptions()
            imageRequestOptions.isSynchronous = true
            let resource = PHAssetResource.assetResources(for: phAsset)
            let imageSizeByte = resource.first?.value(forKey: "fileSize") as? Float ?? 0
            let imageSizeMB = imageSizeByte / (1024.0*1024.0)
            if imageSizeMB > maxSize {
                let alert = UIAlertController(title: "", message: self.t("fileTooLarge"), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: self.t("ok"), style: .default, handler: nil))
                self.viewController?.present(alert, animated: true, completion: nil)
                isValid = false
            }
        }
        if phAsset.mediaType == .video {
            if let maxDuration = self.options!["maxDuration"] as? Double {
                if phAsset.duration > maxDuration {
                    let alert = UIAlertController(title: "", message: self.t("maxDuration"), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: self.t("ok"), style: .default, handler: nil))
                    self.viewController?.present(alert, animated: true, completion: nil)
                    isValid = false
                }
            }
            
        }
        return isValid
    }
    
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        let alert = UIAlertController(title: "", message: self.t("maxSelection"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: self.t("ok"), style: .default, handler: nil))
        picker.present(alert, animated: true, completion: nil)
    }
    
    func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        let alert = UIAlertController(title: "", message: self.t("noAlbumPermission"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: self.t("ok"), style: .default, handler: nil))
        picker.present(alert, animated: true, completion: nil)
    }
    
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        let alert = UIAlertController(title: "", message: self.t("noCameraPermissions"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: self.t("ok"), style: .default, handler: nil))
        picker.present(alert, animated: true, completion: nil)
    }
    
    private func t(_ message: String) -> String {
        let messages = self.options!["messages"] as? NSDictionary
        
        if let m = messages?[message] {
            return m as! String
        }
        
        return message
    }
    
    func topMostViewController() -> UIViewController? {
        var topController = UIApplication.shared.keyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController
    }
}
