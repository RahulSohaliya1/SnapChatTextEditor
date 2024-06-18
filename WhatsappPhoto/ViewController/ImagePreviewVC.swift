//
//  ImagePreviewVC.swift
//  WhatsappPhoto
//
//  Created by DREAMWORLD on 28/05/24.
//

import UIKit
import AVKit

class ImagePreviewVC: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewImgVw: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    
    var previewImage: UIImage?
    var previewVideoURL: URL?
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = previewImage {
                    previewImgVw.image = image
                } else if let videoURL = previewVideoURL {
                    player = AVPlayer(url: videoURL)
                    playerLayer = AVPlayerLayer(player: player)
                    playerLayer?.frame = previewView.bounds
                    previewView.layer.addSublayer(playerLayer!)
                    
                    player?.play()
                }
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
