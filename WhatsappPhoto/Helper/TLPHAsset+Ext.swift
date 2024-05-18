//
//  TLPHAsset+Ext.swift
//  WhatsappPhoto
//
//  Created by PC on 14/11/22.
//

import Foundation
import TLPhotoPicker
import Photos
import MobileCoreServices

extension TLPHAsset {
    private func videoFilename(phAsset: PHAsset) -> URL? {
        guard let resource = (PHAssetResource.assetResources(for: phAsset).filter{ $0.type == .video }).first else {
            return nil
        }
        var writeURL: URL?
        let fileName = resource.originalFilename
        if #available(iOS 10.0, *) {
            writeURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName)")
        } else {
            writeURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("\(fileName)")
        }
        return writeURL
    }
    
    func MIMEType(_ url: URL?) -> String? {
        guard let ext = url?.pathExtension else { return nil }
        if !ext.isEmpty {
            let UTIRef = UTTypeCreatePreferredIdentifierForTag("public.filename-extension" as CFString, ext as CFString, nil)
            let UTI = UTIRef?.takeUnretainedValue()
            UTIRef?.release()
            if let UTI = UTI {
                guard let MIMETypeRef = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType) else { return nil }
                let MIMEType = MIMETypeRef.takeUnretainedValue()
                MIMETypeRef.release()
                return MIMEType as String
            }
        }
        return nil
    }
    
//    AVAssetExportPresetLowQuality
//    AVAssetExportPresetMediumQuality
//    AVAssetExportPresetHighestQuality
//    AVAssetExportPreset640x480
//    AVAssetExportPreset960x540
//    AVAssetExportPreset1280x720
//    AVAssetExportPreset1920x1080
//    AVAssetExportPreset3840x2160
    
    public func exportVideoFileLowQuality(options: PHVideoRequestOptions? = nil,
                                outputURL: URL? = nil,
                                outputFileType: AVFileType = .mp4,
                                progressBlock:((Double) -> Void)? = nil,
                                completionBlock:@escaping ((URL,String) -> Void)) {
        guard
            let phAsset = self.phAsset,
            phAsset.mediaType == .video,
            let writeURL = outputURL ?? videoFilename(phAsset: phAsset),
            let mimetype = MIMEType(writeURL)
            else {
                return
        }
        var requestOptions = PHVideoRequestOptions()
        if let options = options {
            requestOptions = options
        }else {
            requestOptions.isNetworkAccessAllowed = true
        }
        requestOptions.progressHandler = { (progress, error, stop, info) in
            DispatchQueue.main.async {
                progressBlock?(progress)
            }
        }
        PHImageManager.default().requestAVAsset(forVideo: phAsset, options: requestOptions) { (avasset, avaudioMix, infoDict) in
            guard let avasset = avasset else {
                return
            }
            let exportSession = AVAssetExportSession.init(asset: avasset, presetName: AVAssetExportPreset1280x720)
            exportSession?.outputURL = writeURL
            exportSession?.outputFileType = outputFileType
            exportSession?.exportAsynchronously(completionHandler: {
                completionBlock(writeURL, mimetype)
            })
        }
    }
}
