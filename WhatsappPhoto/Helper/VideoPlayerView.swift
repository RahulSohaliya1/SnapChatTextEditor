//
//  VideoPlayerView.swift
//  WhatsappPhoto
//
//  Created by PC on 06/10/22.
//

import UIKit
import AVFoundation
import AVKit

class VideoPlayerView: UIView {
    
    //MARK: Outlets
    private var playPauseButton: UIButton!
    private var loaderView: UIActivityIndicatorView!
    
    //MARK: Internal Properties
    
    //MARK: Private Properties
    private var playerLayer: AVPlayerLayer?
    var player: AVQueuePlayer?
    var playerItems: [AVPlayerItem]?
    
    //MARK: Properties
    var progress: Float = 0
    lazy var playerLooper = AVPlayerLooper(player: player!, templateItem: (playerItems?.first)!)
    
    //MARK: Lifecycle Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame = self.bounds
    }
    
    deinit {
        print("deinit VideoPlayerView")
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
        NotificationCenter.default.removeObserver(self, name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
        NotificationCenter.default.removeObserver(self)
        player = nil
        player?.removeAllItems()
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async {[weak self] in
                    if newStatus == .playing || newStatus == .paused {
                        self?.loaderView.stopAnimating()
                        self?.loaderView.isHidden = true
                    } else {
                        self?.loaderView.startAnimating()
                        self?.loaderView.isHidden = false
                    }
                }
            }
        }
    }
    
    //MARK: Public Methods
    public func loadVideo(with url: URL) {
        self.loadVideos(with: [url])
    }
    
    public func loadVideos(with urls: [URL]) {
        guard !urls.isEmpty else {
            print("🚫 URLs not available.")
            return
        }
        
        guard let player = self.player(with: urls) else {
            print("🚫 AVPlayer not created.")
            return
        }
        
        self.player = player
        let playerLayer = self.playerLayer(with: player)
        playerLayer.videoGravity = .resizeAspectFill
        self.layer.insertSublayer(playerLayer, at: 0)
        guard playerLooper.error == nil else { return }

        playVideo()
    }
    
    public func playVideo() {
        self.player?.play()
        self.playPauseButton.isSelected = true
    }
    
    public func pauseVideo() {
        self.player?.pause()
        self.playPauseButton.isSelected = false
    }
    
    //MARK: Button Action Methods
    @IBAction private func onTapPlayPauseVideoButton(_ sender: UIButton) {
        if sender.isSelected {
            self.pauseVideo()
        } else {
            self.playVideo()
        }
    }
}

// MARK: - Private Methods
private extension VideoPlayerView {
    func setupUI() {
        playPauseButton = UIButton(type: .custom)
        playPauseButton.backgroundColor = .clear
        playPauseButton.isHidden = true
        self.addSubview(playPauseButton)
        
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        playPauseButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        playPauseButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        playPauseButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        
        playPauseButton.addTarget(self, action: #selector(onTapPlayPauseVideoButton(_:)), for: .touchUpInside)
        playPauseButton.setImage(UIImage(named: "ic_play"), for: .normal)
        playPauseButton.setImage(UIImage(), for: .selected)
        
        loaderView = UIActivityIndicatorView(style: .large)
        self.addSubview(loaderView)
        loaderView.isHidden = true
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loaderView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    func player(with urls: [URL]) -> AVQueuePlayer? {
        var playerItems = [AVPlayerItem]()
        
        urls.forEach { (url) in
            let asset = AVAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            playerItems.append(playerItem)
        }
        
        guard !playerItems.isEmpty else {
            return nil
        }
        
        let player = AVQueuePlayer(items: playerItems)
        self.playerItems = playerItems
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: DispatchQueue.main) {[weak self] (progressTime) in
            if let duration = player.currentItem?.duration {
                
                let durationSeconds = CMTimeGetSeconds(duration)
                let seconds = CMTimeGetSeconds(progressTime)
                let progress = Float(seconds/durationSeconds)
                
                DispatchQueue.main.async {
                    self?.progress = progress
                    if progress >= 1.0 {
                        self?.progress = 0.0
                    }
                }
            }
        }
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerEndedPlaying), name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
        
        return player
    }
    
    func playerLayer(with player: AVQueuePlayer) -> AVPlayerLayer {
        self.layoutIfNeeded()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        playerLayer.videoGravity = .resizeAspect
        playerLayer.contentsGravity = .resizeAspect
        self.playerLayer = playerLayer
        return playerLayer
    }
    
    @objc func playerEndedPlaying(_ notification: Notification) {
        DispatchQueue.main.async {[weak self] in
            if let playerItem = notification.object as? AVPlayerItem {
                if playerItem == self?.playerItems?.last {
                    self?.pauseVideo()
                }
                //                self?.player?.remove(playerItem)
                //                playerItem.seek(to: .zero, completionHandler: nil)
                //                self?.player?.insert(playerItem, after: nil)
                if self?.playerItems?.contains(playerItem) == true {
                    self?.player?.remove(playerItem)
                    playerItem.seek(to: .zero, completionHandler: nil)
                    self?.player?.insert(playerItem, after: nil)
                }
            }
        }
    }
}

//extension AVPlayer {
//    func generateThumbnail(time: CMTime = CMTime(seconds: 1, preferredTimescale: 2)) -> UIImage? {
//        guard let asset = currentItem?.asset else { return nil }
//        let imageGenerator = AVAssetImageGenerator(asset: asset)
//
//        do {
//            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
//            return UIImage(cgImage: cgImage)
//        } catch {
//            print(error.localizedDescription)
//        }
//
//        return nil
//    }
//}
