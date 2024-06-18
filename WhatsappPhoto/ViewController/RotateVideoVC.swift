//
//  RotateVideoVC.swift
//  MeetUrFriends
//
//  Created by DREAMWORLD on 12/06/24.
//

import UIKit
import AVFoundation
import AVKit

class RotateVideoVC: UIViewController {
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var currentRotationAngle: CGFloat = 0
    var videoURL: URL?
    var completion: ((URL)->Void)?
    var currentScale: CGFloat = 1.0
    
    let cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ic_close"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let doneBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ic_send_green"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        // Load the video file
        guard let videoURL = videoURL else {
            return
        }
        
        // Add rotation gesture recognizer
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        self.view.addGestureRecognizer(rotationGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        self.view.addGestureRecognizer(pinchGestureRecognizer)
        
        // Play the video with the current rotation
        playVideo(with: videoURL, angle: currentRotationAngle)
        
        view.addSubview(cancelBtn)
        view.addSubview(doneBtn)
        
        cancelBtn.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        cancelBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        cancelBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        cancelBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        cancelBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        doneBtn.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        doneBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        doneBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        doneBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        doneBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    @objc private func didTapCancelButton() {
        self.dismiss(animated: false)
    }
    
    @objc private func didTapDoneButton() {
        //        exportTransformedVideo(inputURL: videoURL!, rotationAngle: currentRotationAngle, scale: currentScale) { [weak self] outputURL in
        //            guard let self = self, let outputURL = outputURL else { return }
        //
        //            // Play the exported video
        //            DispatchQueue.main.async {
        ////                hideLoader()
        //                self.completion?(outputURL)
        //                self.dismiss(animated: false)
        //            }
        //        }
        //
        //        exportRotatedVideo(inputURL: videoURL!, angle: currentRotationAngle) { [weak self] outputURL in
        //            guard let self = self, let outputURL = outputURL else { return }
        //
        //            // Play the exported video
        //            DispatchQueue.main.async {
        ////                hideLoader()
        //                self.completion?(outputURL)
        //                self.dismiss(animated: false)
        //            }
        //        }
        
        guard let videoURL = videoURL else { return }
        
        let asset = AVAsset(url: videoURL)
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        
        let videoComposition = AVMutableVideoComposition()
        let videoTrack = asset.tracks(withMediaType: .video).first!
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        let transform = currentTransform()
        transformer.setTransform(transform, at: .zero)
        
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        // Calculate transformed size
        let transformedSize = videoTrack.naturalSize.applying(transform)
        
        // Ensure render size is positive
        videoComposition.renderSize = CGSize(width: abs(transformedSize.width), height: abs(transformedSize.height))
        
        // Calculate frame duration based on video's timebase
        let frameDuration = CMTime(seconds: 1.0 / Double(videoTrack.nominalFrameRate), preferredTimescale: 600)
        videoComposition.frameDuration = frameDuration
        
        exportSession.videoComposition = videoComposition
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentsDirectory.appendingPathComponent("rotated_scaled_video.mov")
        
        try? FileManager.default.removeItem(at: outputURL)
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov
        
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .completed:
                    self.completion?(outputURL)
                    self.dismiss(animated: true)
                case .failed:
                    if let error = exportSession.error {
                        print("Export failed: \(error.localizedDescription)")
                    }
                case .cancelled:
                    print("Export cancelled")
                default:
                    break
                }
            }
        }
        
    }
    
    @objc func handleRotation(_ sender: UIRotationGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            // Update the current rotation angle
            currentRotationAngle += sender.rotation
            sender.rotation = 0
            rotateVideoLayer(angle: currentRotationAngle)
            // Save the current rotation angle
            //            UserDefaults.standard.set(currentRotationAngle, forKey: "videoRotationAngle")
        } else if sender.state == .ended {
            // Load the video file
        }
    }
    
    func rotateVideoLayer(angle: CGFloat) {
        // Create a rotation transform
        let rotationTransform = CATransform3DMakeRotation(angle, 0, 0, 1)
        
        // Apply the rotation transform to the playerLayer
        playerLayer.transform = rotationTransform
    }
    
    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            // Update the current scale
            currentScale *= sender.scale
            sender.scale = 1
            
            // Check if the scale is less than 1 (zoom out)
            if currentScale < 1.0 {
                // Reset the scale to 1.0 (original size)
                currentScale = 1.0
            }
            
            // Save the current scale
            UserDefaults.standard.set(currentScale, forKey: "videoScale")
            
            // Apply transformations
            applyTransformations()
        }
    }
    
    func applyTransformations() {
        // Create a rotation transform
        let rotationTransform = CGAffineTransform(rotationAngle: currentRotationAngle)
        // Create a scale transform
        let scaleTransform = CGAffineTransform(scaleX: currentScale, y: currentScale)
        // Combine the transforms
        let combinedTransform = rotationTransform.concatenating(scaleTransform)
        
        // Apply the combined transform to the playerLayer
        playerLayer.setAffineTransform(combinedTransform)
    }
    
    func playVideo(with url: URL, angle: CGFloat) {
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        
        // Create a rotation transform
        //        let rotationTransform = CATransform3DMakeRotation(angle, 0, 0, 1)
        //        playerLayer.transform = rotationTransform
        
        applyTransformations()
        
        // Add the playerLayer to the view's layer
        self.view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.view.layer.addSublayer(playerLayer)
        
        // Start playing the video
        //        player.play()
    }
    
    func currentTransform() -> CGAffineTransform {
        let rotationTransform = CGAffineTransform(rotationAngle: currentRotationAngle)
        let scaleTransform = CGAffineTransform(scaleX: currentScale, y: currentScale)
        return rotationTransform.concatenating(scaleTransform)
    }
    
    
    func exportTransformedVideo(inputURL: URL, rotationAngle: CGFloat, scale: CGFloat, completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: inputURL)
        let composition = AVMutableComposition()
        
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            print("Error: Unable to get video track.")
            completion(nil)
            return
        }
        
        // Create a composition track for the video
        guard let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            print("Error: Unable to create video composition track.")
            completion(nil)
            return
        }
        
        do {
            try videoCompositionTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: videoTrack, at: .zero)
        } catch {
            print("Error inserting time range into video composition track: \(error)")
            completion(nil)
            return
        }
        
        // Create a video composition to apply the transformations
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoTrack.naturalSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        let translation = CGAffineTransform(translationX: videoTrack.naturalSize.width / 2, y: videoTrack.naturalSize.height / 2)
        let rotation = translation.rotated(by: rotationAngle)
        let scaling = rotation.scaledBy(x: scale, y: scale)
        let finalTransform = scaling.translatedBy(x: -videoTrack.naturalSize.width / 2, y: -videoTrack.naturalSize.height / 2)
        transformer.setTransform(finalTransform, at: .zero)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        instruction.layerInstructions = [transformer]
        
        videoComposition.instructions = [instruction]
        
        // Export the video with the applied transformations
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            print("Error: Unable to create AVAssetExportSession.")
            completion(nil)
            return
        }
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = videoComposition
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(outputURL)
            case .failed:
                print("Export failed: \(String(describing: exportSession.error))")
                completion(nil)
            case .cancelled:
                print("Export cancelled: \(String(describing: exportSession.error))")
                completion(nil)
            default:
                print("Export unknown error: \(String(describing: exportSession.error))")
                completion(nil)
            }
        }
    }
    
    func exportRotatedVideo(inputURL: URL, angle: CGFloat, completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: inputURL)
        let composition = AVMutableComposition()
        
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            completion(nil)
            return
        }
        
        // Create a composition track for the video
        guard let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            completion(nil)
            return
        }
        
        do {
            try videoCompositionTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: videoTrack, at: .zero)
        } catch {
            completion(nil)
            return
        }
        
        // Create a video composition to apply the rotation
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoTrack.naturalSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        let t1 = CGAffineTransform(translationX: videoTrack.naturalSize.width / 2, y: videoTrack.naturalSize.height / 2)
        let t2 = t1.rotated(by: angle)
        let t3 = t2.translatedBy(x: -videoTrack.naturalSize.width / 2, y: -videoTrack.naturalSize.height / 2)
        transformer.setTransform(t3, at: .zero)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        instruction.layerInstructions = [transformer]
        
        videoComposition.instructions = [instruction]
        
        // Export the video with the applied rotation
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
        exportSession?.outputURL = outputURL
        exportSession?.outputFileType = .mp4
        exportSession?.videoComposition = videoComposition
        
        exportSession?.exportAsynchronously {
            switch exportSession?.status {
            case .completed:
                completion(outputURL)
            default:
                completion(nil)
            }
        }
    }
}
