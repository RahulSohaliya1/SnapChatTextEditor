/*Copyright (c) 2016, Andrew Walz.
 
 Redistribution and use in source and binary forms, with or without modification,are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
 BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import AVFoundation

open class SwiftyCamViewController: UIViewController {
    
    public enum CameraSelection: String {
        case rear = "rear"
        case front = "front"
    }
    
    public enum FlashMode{
        var AVFlashMode: AVCaptureDevice.FlashMode {
            switch self {
            case .on:
                return .on
            case .off:
                return .off
            case .auto:
                return .auto
            }
        }
        case auto
        case on
        case off
    }
    
    public enum VideoQuality {
        /// AVCaptureSessionPresetHigh
        case high
        case medium
        case low
        case resolution352x288
        case resolution640x480
        case resolution1280x720
        case resolution1920x1080
        case resolution3840x2160
        case iframe960x540
        case iframe1280x720
    }
    
    fileprivate enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    public weak var cameraDelegate: SwiftyCamViewControllerDelegate?
    
    public var maximumVideoDuration : Double     = 0.0
    
    public var videoQuality : VideoQuality       = .high
    
    @available(*, deprecated, message: "use flashMode .on or .off") //use flashMode
    public var flashEnabled: Bool = false {
        didSet{
            self.flashMode = self.flashEnabled ? .on : .off
        }
    }
    
    public var flashMode:FlashMode               = .off
    public var pinchToZoom                       = true
    public var maxZoomScale                         = CGFloat.greatestFiniteMagnitude
    public var tapToFocus                        = true
    public var lowLightBoost                     = true
    public var allowBackgroundAudio              = true
    public var doubleTapCameraSwitch            = true
    public var swipeToZoom                     = true
    public var swipeToZoomInverted             = false
    public var defaultCamera                   = CameraSelection.rear
    public var shouldUseDeviceOrientation      = false {
        didSet {
            orientation.shouldUseDeviceOrientation = shouldUseDeviceOrientation
        }
    }
    
    public var allowAutoRotate                = false
    public var videoGravity                   : SwiftyCamVideoGravity = .resizeAspectFill
    public var audioEnabled                   = true
    public var shouldPrompToAppSettings       = true
    public var outputFolder: String           = NSTemporaryDirectory()
    fileprivate(set) public var pinchGesture  : UIPinchGestureRecognizer!
    fileprivate(set) public var panGesture    : UIPanGestureRecognizer!
    private(set) public var isVideoRecording      = false
    private(set) public var isSessionRunning     = false
    private(set) public var currentCamera        = CameraSelection.rear
    public let session                           = AVCaptureSession()
    fileprivate let sessionQueue                 = DispatchQueue(label: "session queue", attributes: [])
    fileprivate var zoomScale                    = CGFloat(1.0)
    fileprivate var beginZoomScale               = CGFloat(1.0)
    fileprivate var isCameraTorchOn              = false
    fileprivate var setupResult                  = SessionSetupResult.success
    fileprivate var backgroundRecordingID        : UIBackgroundTaskIdentifier? = nil
    fileprivate var videoDeviceInput             : AVCaptureDeviceInput!
    fileprivate var movieFileOutput              : AVCaptureMovieFileOutput?
    fileprivate var photoFileOutput              : AVCaptureStillImageOutput?
    fileprivate var videoDevice                  : AVCaptureDevice?
    fileprivate var previewLayer                 : PreviewView!
    fileprivate var flashView                    : UIView?
    fileprivate var previousPanTranslation       : CGFloat = 0.0
    fileprivate var orientation                  : Orientation = Orientation()
    fileprivate var sessionRunning               = false
    
    override open var shouldAutorotate: Bool {
        return allowAutoRotate
    }
    
    public var videoCodecType: AVVideoCodecType? = nil
    
    private var progressBlock: ((Float,String)-> Void)!
    private var finishedBlock: ((URL?, Error?)-> Void)!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        previewLayer = PreviewView(frame: view.frame, videoGravity: videoGravity)
        previewLayer.center = view.center
        view.addSubview(previewLayer)
        view.sendSubviewToBack(previewLayer)
        addGestureRecognizers()
        previewLayer.session = session
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [unowned self] granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
        default:
            setupResult = .notAuthorized
        }
        sessionQueue.async { [unowned self] in
            self.configureSession()
        }
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        
        if(shouldAutorotate){
            layer.videoOrientation = orientation
        } else {
            layer.videoOrientation = .portrait
        }
        previewLayer.frame = self.view.bounds
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection =  self.previewLayer?.videoPreviewLayer.connection  {
            
            let currentDevice: UIDevice = UIDevice.current
            
            let orientation: UIDeviceOrientation = currentDevice.orientation
            
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                
                switch (orientation) {
                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                    
                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                    break
                    
                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                    break
                    
                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                    break
                    
                default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                }
            }
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(captureSessionDidStartRunning), name: .AVCaptureSessionDidStartRunning, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(captureSessionDidStopRunning),  name: .AVCaptureSessionDidStopRunning,  object: nil)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldUseDeviceOrientation {
            orientation.start()
        }
        
        setBackgroundAudioPreference()
        
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                DispatchQueue.main.async {
                    self.previewLayer.videoPreviewLayer.connection?.videoOrientation = self.orientation.getPreviewLayerOrientation()
                }
            case .notAuthorized:
                if self.shouldPrompToAppSettings == true {
                    self.promptToAppSettings()
                } else {
                    self.cameraDelegate?.swiftyCamNotAuthorized(self)
                }
            case .configurationFailed:
                DispatchQueue.main.async {
                    self.cameraDelegate?.swiftyCamDidFailToConfigure(self)
                }
            }
        }
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        sessionRunning = false
        
        if self.isSessionRunning == true {
            self.session.stopRunning()
            self.isSessionRunning = false
        }
        
        disableFlash()
        
        if shouldUseDeviceOrientation {
            orientation.stop()
        }
    }
    
    public func takePhoto() {
        
        guard let device = videoDevice else { return }
        
        if device.hasFlash == true && flashMode != .off /* TODO: Add Support for Retina Flash and add front flash */ {
            changeFlashSettings(device: device, mode: flashMode)
            capturePhotoAsyncronously(completionHandler: { (_) in })
        }else{
            if device.isFlashActive == true {
                changeFlashSettings(device: device, mode: flashMode)
            }
            capturePhotoAsyncronously(completionHandler: { (_) in })
        }
    }
    
    
    
    public func startVideoRecording() {
        
        guard sessionRunning == true else {
            print("[SwiftyCam]: Cannot start video recoding. Capture session is not running")
            return
        }
        guard let movieFileOutput = self.movieFileOutput else { return }
        
        if currentCamera == .rear && flashMode == .on {
            enableFlash()
        }
        
        if currentCamera == .front && flashMode == .on  {
            flashView = UIView(frame: view.frame)
            flashView?.backgroundColor = UIColor.white
            flashView?.alpha = 0.85
            previewLayer.addSubview(flashView!)
        }
        
        guard let previewOrientation = previewLayer.videoPreviewLayer.connection?.videoOrientation else { print("No Cam"); return }
        
        sessionQueue.async { [unowned self] in
            if !movieFileOutput.isRecording {
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                
                let movieFileOutputConnection = self.movieFileOutput?.connection(with: AVMediaType.video)
                //flip video output if front facing camera is selected
                if self.currentCamera == .front {
                    movieFileOutputConnection?.isVideoMirrored = true
                }
                
                movieFileOutputConnection?.videoOrientation = self.orientation.getVideoOrientation() ?? previewOrientation
                // Start recording to a temporary file.
                let outputFileName = UUID().uuidString
                let outputFilePath = (self.outputFolder as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
                self.isVideoRecording = true
                DispatchQueue.main.async {
                    self.cameraDelegate?.swiftyCam(self, didBeginRecordingVideo: self.currentCamera)
                }
            }
            else {
                movieFileOutput.stopRecording()
            }
        }
    }
    
    public func stopVideoRecording() {
        if self.isVideoRecording == true {
            self.isVideoRecording = false
            movieFileOutput!.stopRecording()
            disableFlash()
            
            if currentCamera == .front && flashMode == .on && flashView != nil {
                UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.flashView?.alpha = 0.0
                }, completion: { (_) in
                    self.flashView?.removeFromSuperview()
                })
            }
            DispatchQueue.main.async {
                self.cameraDelegate?.swiftyCam(self, didFinishRecordingVideo: self.currentCamera)
            }
        }
    }
    public func switchCamera() {
        guard isVideoRecording != true else {
            //TODO: Look into switching camera during video recording
            print("[SwiftyCam]: Switching between cameras while recording video is not supported")
            return
        }
        
        guard session.isRunning == true else { return }
        
        switch currentCamera {
        case .front:
            currentCamera = .rear
        case .rear:
            currentCamera = .front
        }
        
        session.stopRunning()
        
        sessionQueue.async { [unowned self] in
            for input in self.session.inputs {
                self.session.removeInput(input )
            }
            
            self.addInputs()
            DispatchQueue.main.async {
                self.cameraDelegate?.swiftyCam(self, didSwitchCameras: self.currentCamera)
            }
            self.session.startRunning()
        }
        disableFlash()
    }
    
    fileprivate func configureSession() {
        guard setupResult == .success else { return }
        
        currentCamera = defaultCamera
        
        session.beginConfiguration()
        configureVideoPreset()
        addVideoInput()
        addAudioInput()
        configureVideoOutput()
        configurePhotoOutput()
        
        session.commitConfiguration()
    }
    
    fileprivate func addInputs() {
        session.beginConfiguration()
        configureVideoPreset()
        addVideoInput()
        addAudioInput()
        session.commitConfiguration()
    }
    
    fileprivate func configureVideoPreset() {
        if currentCamera == .front {
            session.sessionPreset = AVCaptureSession.Preset(rawValue: videoInputPresetFromVideoQuality(quality: .high))
        } else {
            if session.canSetSessionPreset(AVCaptureSession.Preset(rawValue: videoInputPresetFromVideoQuality(quality: videoQuality))) {
                session.sessionPreset = AVCaptureSession.Preset(rawValue: videoInputPresetFromVideoQuality(quality: videoQuality))
            } else {
                session.sessionPreset = AVCaptureSession.Preset(rawValue: videoInputPresetFromVideoQuality(quality: .high))
            }
        }
    }
    
    fileprivate func addVideoInput() {
        switch currentCamera {
        case .front:
            videoDevice = SwiftyCamViewController.deviceWithMediaType(AVMediaType.video.rawValue, preferringPosition: .front)
        case .rear:
            videoDevice = SwiftyCamViewController.deviceWithMediaType(AVMediaType.video.rawValue, preferringPosition: .back)
        }
        
        if let device = videoDevice {
            do {
                try device.lockForConfiguration()
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    device.focusMode = .continuousAutoFocus
                    if device.isSmoothAutoFocusSupported {
                        device.isSmoothAutoFocusEnabled = true
                    }
                }
                if device.isExposureModeSupported(.continuousAutoExposure) {
                    device.exposureMode = .continuousAutoExposure
                }
                if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                    device.whiteBalanceMode = .continuousAutoWhiteBalance
                }
                if device.isLowLightBoostSupported && lowLightBoost == true {
                    device.automaticallyEnablesLowLightBoostWhenAvailable = true
                }
                
                device.unlockForConfiguration()
            } catch {
                print("[SwiftyCam]: Error locking configuration")
            }
        }
        
        do {
            if let videoDevice = videoDevice {
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                if session.canAddInput(videoDeviceInput) {
                    session.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                } else {
                    print("[SwiftyCam]: Could not add video device input to the session")
                    print(session.canSetSessionPreset(AVCaptureSession.Preset(rawValue: videoInputPresetFromVideoQuality(quality: videoQuality))))
                    setupResult = .configurationFailed
                    session.commitConfiguration()
                    return
                }
            }
            
        } catch {
            print("[SwiftyCam]: Could not create video device input: \(error)")
            setupResult = .configurationFailed
            return
        }
    }
    
    fileprivate func addAudioInput() {
        guard audioEnabled == true else {
            return
        }
        do {
            if let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio){
                let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
                if session.canAddInput(audioDeviceInput) {
                    session.addInput(audioDeviceInput)
                } else {
                    print("[SwiftyCam]: Could not add audio device input to the session")
                }
                
            } else {
                print("[SwiftyCam]: Could not find an audio device")
            }
            
        } catch {
            print("[SwiftyCam]: Could not create audio device input: \(error)")
        }
    }
    
    fileprivate func configureVideoOutput() {
        let movieFileOutput = AVCaptureMovieFileOutput()
        
        if self.session.canAddOutput(movieFileOutput) {
            self.session.addOutput(movieFileOutput)
            if let connection = movieFileOutput.connection(with: AVMediaType.video) {
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
                
                if #available(iOS 11.0, *) {
                    if let videoCodecType = videoCodecType {
                        if movieFileOutput.availableVideoCodecTypes.contains(videoCodecType) == true {
                            // Use the H.264 codec to encode the video.
                            movieFileOutput.setOutputSettings([AVVideoCodecKey: videoCodecType], for: connection)
                        }
                    }
                }
            }
            self.movieFileOutput = movieFileOutput
        }
    }
    
    fileprivate func configurePhotoOutput() {
        let photoFileOutput = AVCaptureStillImageOutput()
        
        if self.session.canAddOutput(photoFileOutput) {
            photoFileOutput.outputSettings  = [AVVideoCodecKey: AVVideoCodecJPEG]
            self.session.addOutput(photoFileOutput)
            self.photoFileOutput = photoFileOutput
        }
    }
    
    fileprivate func processPhoto(_ imageData: Data) -> UIImage {
        let dataProvider = CGDataProvider(data: imageData as CFData)
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
        
        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: self.orientation.getImageOrientation(forCamera: self.currentCamera))
        return image
    }
    
    fileprivate func capturePhotoAsyncronously(completionHandler: @escaping(Bool) -> ()) {
        guard sessionRunning == true else {
            print("[SwiftyCam]: Cannot take photo. Capture session is not running")
            return
        }
        
        if let videoConnection = photoFileOutput?.connection(with: AVMediaType.video) {
            photoFileOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer!)
                    let image = self.processPhoto(imageData!)
                    
                    // Call delegate and return new image
                    DispatchQueue.main.async {
                        self.cameraDelegate?.swiftyCam(self, didTake: image)
                    }
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            })
        } else {
            completionHandler(false)
        }
    }
    
    fileprivate func promptToAppSettings() {
        DispatchQueue.main.async(execute: { [unowned self] in
            let message = NSLocalizedString("AVCam doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
            let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .default, handler: { action in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                } else {
                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.openURL(appSettings)
                    }
                }
            }))
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    fileprivate func videoInputPresetFromVideoQuality(quality: VideoQuality) -> String {
        switch quality {
        case .high: return AVCaptureSession.Preset.high.rawValue
        case .medium: return AVCaptureSession.Preset.medium.rawValue
        case .low: return AVCaptureSession.Preset.low.rawValue
        case .resolution352x288: return AVCaptureSession.Preset.cif352x288.rawValue
        case .resolution640x480: return AVCaptureSession.Preset.vga640x480.rawValue
        case .resolution1280x720: return AVCaptureSession.Preset.hd1280x720.rawValue
        case .resolution1920x1080: return AVCaptureSession.Preset.hd1920x1080.rawValue
        case .iframe960x540: return AVCaptureSession.Preset.iFrame960x540.rawValue
        case .iframe1280x720: return AVCaptureSession.Preset.iFrame1280x720.rawValue
        case .resolution3840x2160:
            if #available(iOS 9.0, *) {
                return AVCaptureSession.Preset.hd4K3840x2160.rawValue
            }
            else {
                print("[SwiftyCam]: Resolution 3840x2160 not supported")
                return AVCaptureSession.Preset.high.rawValue
            }
        }
    }
    
    fileprivate class func deviceWithMediaType(_ mediaType: String, preferringPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if #available(iOS 10.0, *) {
            let avDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType(rawValue: mediaType), position: position)
            return avDevice
        } else {
            // Fallback on earlier versions
            let avDevice = AVCaptureDevice.devices(for: AVMediaType(rawValue: mediaType))
            var avDeviceNum = 0
            for device in avDevice {
                print("deviceWithMediaType Position: \(device.position.rawValue)")
                if device.position == position {
                    break
                } else {
                    avDeviceNum += 1
                }
            }
            return avDevice[avDeviceNum]
        }
    }
    
    fileprivate func changeFlashSettings(device: AVCaptureDevice, mode: FlashMode) {
        do {
            try device.lockForConfiguration()
            device.flashMode = mode.AVFlashMode
            device.unlockForConfiguration()
        } catch {
            print("[SwiftyCam]: \(error)")
        }
    }
    
    fileprivate func enableFlash() {
        if self.isCameraTorchOn == false {
            toggleFlash()
        }
    }
    
    fileprivate func disableFlash() {
        if self.isCameraTorchOn == true {
            toggleFlash()
        }
    }
    
    fileprivate func toggleFlash() {
        guard self.currentCamera == .rear else {
            return
        }
        
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureDevice.TorchMode.on) {
                    device?.torchMode = AVCaptureDevice.TorchMode.off
                    self.isCameraTorchOn = false
                } else {
                    do {
                        try device?.setTorchModeOn(level: 1.0)
                        self.isCameraTorchOn = true
                    } catch {
                        print("[SwiftyCam]: \(error)")
                    }
                }
                device?.unlockForConfiguration()
            } catch {
                print("[SwiftyCam]: \(error)")
            }
        }
    }
    
    fileprivate func setBackgroundAudioPreference() {
        guard allowBackgroundAudio == true else { return }
        
        guard audioEnabled == true else { return }
        
        do{
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
            } else {
                let options: [AVAudioSession.CategoryOptions] = [.mixWithOthers, .allowBluetooth]
                let category = AVAudioSession.Category.playAndRecord
                let selector = NSSelectorFromString("setCategory:withOptions:error:")
                AVAudioSession.sharedInstance().perform(selector, with: category, with: options)
            }
            try AVAudioSession.sharedInstance().setActive(true)
            session.automaticallyConfiguresApplicationAudioSession = false
        }
        catch {
            print("[SwiftyCam]: Failed to set background audio preference")
            
        }
    }
    
    @objc private func captureSessionDidStartRunning() {
        sessionRunning = true
        DispatchQueue.main.async {
            self.cameraDelegate?.swiftyCamSessionDidStartRunning(self)
        }
    }
    
    @objc private func captureSessionDidStopRunning() {
        sessionRunning = false
        DispatchQueue.main.async {
            self.cameraDelegate?.swiftyCamSessionDidStopRunning(self)
        }
    }
}

extension SwiftyCamViewController : SwiftyCamButtonDelegate {
    
    public func setMaxiumVideoDuration() -> Double {
        return maximumVideoDuration
    }
    
    public func buttonWasTapped() {
        takePhoto()
    }
    
    public func buttonDidBeginLongPress() {
        startVideoRecording()
    }
    
    public func buttonDidEndLongPress() {
        stopVideoRecording()
    }
    
    public func longPressDidReachMaximumDuration() {
        stopVideoRecording()
    }
}

extension SwiftyCamViewController : AVCaptureFileOutputRecordingDelegate {
    
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let currentBackgroundRecordingID = backgroundRecordingID {
            backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
            
            if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
                UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
            }
        }
        
        if let currentError = error {
            print("[SwiftyCam]: Movie file finishing error: \(currentError)")
            DispatchQueue.main.async {
                self.cameraDelegate?.swiftyCam(self, didFailToRecordVideo: currentError)
            }
        } else {
            //Call delegate function with the URL of the outputfile
            DispatchQueue.main.async {
                self.cameraDelegate?.swiftyCam(self, didFinishProcessVideoAt: outputFileURL)
            }
        }
    }
}

extension SwiftyCamViewController {
    
    @objc fileprivate func zoomGesture(pinch: UIPinchGestureRecognizer) {
        guard pinchToZoom == true && self.currentCamera == .rear else {
            return
        }
        do {
            let captureDevice = AVCaptureDevice.devices().first
            try captureDevice?.lockForConfiguration()
            
            zoomScale = min(maxZoomScale, max(1.0, min(beginZoomScale * pinch.scale,  captureDevice!.activeFormat.videoMaxZoomFactor)))
            captureDevice?.videoZoomFactor = zoomScale
            
            // Call Delegate function with current zoom scale
            DispatchQueue.main.async {
                self.cameraDelegate?.swiftyCam(self, didChangeZoomLevel: self.zoomScale)
            }
            captureDevice?.unlockForConfiguration()
        } catch {
            print("[SwiftyCam]: Error locking configuration")
        }
    }
    
    @objc fileprivate func singleTapGesture(tap: UITapGestureRecognizer) {
        guard tapToFocus == true else {
            return
        }
        
        let screenSize = previewLayer!.bounds.size
        let tapPoint = tap.location(in: previewLayer!)
        let x = tapPoint.y / screenSize.height
        let y = 1.0 - tapPoint.x / screenSize.width
        let focusPoint = CGPoint(x: x, y: y)
        
        if let device = videoDevice {
            do {
                try device.lockForConfiguration()
                
                if device.isFocusPointOfInterestSupported == true {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .autoFocus
                }
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
                
                DispatchQueue.main.async {
                    self.cameraDelegate?.swiftyCam(self, didFocusAtPoint: tapPoint)
                }
            }
            catch { }
        }
    }
    
    @objc fileprivate func doubleTapGesture(tap: UITapGestureRecognizer) {
        guard doubleTapCameraSwitch == true else {
            return
        }
        switchCamera()
    }
    
    @objc private func panGesture(pan: UIPanGestureRecognizer) {
        
        guard swipeToZoom == true && self.currentCamera == .rear else {
            return
        }
        let currentTranslation    = pan.translation(in: view).y
        let translationDifference = currentTranslation - previousPanTranslation
        
        do {
            let captureDevice = AVCaptureDevice.devices().first
            try captureDevice?.lockForConfiguration()
            
            let currentZoom = captureDevice?.videoZoomFactor ?? 0.0
            
            if swipeToZoomInverted == true {
                zoomScale = min(maxZoomScale, max(1.0, min(currentZoom - (translationDifference / 75),  captureDevice!.activeFormat.videoMaxZoomFactor)))
            } else {
                zoomScale = min(maxZoomScale, max(1.0, min(currentZoom + (translationDifference / 75),  captureDevice!.activeFormat.videoMaxZoomFactor)))
            }
            captureDevice?.videoZoomFactor = zoomScale
            
            DispatchQueue.main.async {
                self.cameraDelegate?.swiftyCam(self, didChangeZoomLevel: self.zoomScale)
            }
            captureDevice?.unlockForConfiguration()
            
        } catch {
            print("[SwiftyCam]: Error locking configuration")
        }
        
        if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            previousPanTranslation = 0.0
        } else {
            previousPanTranslation = currentTranslation
        }
    }
    
    fileprivate func addGestureRecognizers() {
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomGesture(pinch:)))
        pinchGesture.delegate = self
        previewLayer.addGestureRecognizer(pinchGesture)
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapGesture(tap:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.delegate = self
        previewLayer.addGestureRecognizer(singleTapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapGesture(tap:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = self
        previewLayer.addGestureRecognizer(doubleTapGesture)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(pan:)))
        panGesture.delegate = self
        previewLayer.addGestureRecognizer(panGesture)
    }
}

extension SwiftyCamViewController : UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) {
            beginZoomScale = zoomScale;
        }
        return true
    }
}

extension SwiftyCamViewController {
    
    func adjustPlaybackSpeed(path: URL, speed: Float, progress: @escaping (Float, String) -> Void, finish: @escaping (URL?, Error?) -> Void) {
        // Ensure speed is valid
        guard speed == 0.5 || speed == 1.0 || speed == 2.0 else {
            finish(nil, NSError(domain: "Invalid speed", code: -999, userInfo: nil))
            return
        }
        
        let asset = AVAsset(url: path)
        let composition = AVMutableComposition()
        
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            finish(nil, NSError(domain: "Video track not found", code: -998, userInfo: nil))
            return
        }
        
        let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        
        guard let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            finish(nil, NSError(domain: "Failed to create video composition track", code: -997, userInfo: nil))
            return
        }
        
        do {
            try videoCompositionTrack.insertTimeRange(timeRange, of: videoTrack, at: .zero)
        } catch {
            finish(nil, error)
            return
        }
        
        videoCompositionTrack.scaleTimeRange(timeRange, toDuration: CMTimeMultiplyByFloat64(asset.duration, multiplier: 1.0 / Float64(speed)))
        
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            finish(nil, NSError(domain: "Failed to create export session", code: -996, userInfo: nil))
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                finish(exportSession.outputURL, nil)
            case .failed, .cancelled:
                finish(nil, exportSession.error)
            default:
                break
            }
        }
        
        // Periodically report progress
        let progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            progress(exportSession.progress, "Processing")
            if exportSession.progress >= 1.0 {
                timer.invalidate()
            }
        }
        
        // Add the timer to the current run loop
        RunLoop.current.add(progressTimer, forMode: .common)
    }
}
