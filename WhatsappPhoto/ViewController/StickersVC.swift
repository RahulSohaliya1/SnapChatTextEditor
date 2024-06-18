//
//  StickersVC.swift
//  MeetUrFriends
//
//  Created by DREAMWORLD on 03/06/24.
//

import UIKit

class StickersCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var stickerImgView: UIImageView!
}

class StickersVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var stickers = [UIImage(named: "01_Cuppy_smile"), UIImage(named: "avocado"), UIImage(named: "balloons"), UIImage(named: "bunting"), UIImage(named: "cake"), UIImage(named: "confetti"), UIImage(named: "garland"), UIImage(named: "heart"), UIImage(named: "hello"), UIImage(named: "milkshake"), UIImage(named: "moon"), UIImage(named: "panda"), UIImage(named: "pizza"), UIImage(named: "rainbow"), UIImage(named: "rob"), UIImage(named: "star"), UIImage(named: "sun"), UIImage(named: "wreath"), UIImage(named: "banana"), UIImage(named: "fried-egg"), UIImage(named: "pancake"), UIImage(named: "sandwich"), UIImage(named: "vegetable"), UIImage(named: "wine"), UIImage(named: "rocket"), UIImage(named: "victory"), UIImage(named: "glasses"), UIImage(named: "arrow-down"), UIImage(named: "award"), UIImage(named: "bravo"), UIImage(named: "butterfly"), UIImage(named: "good-morning"), UIImage(named: "sparrow"), UIImage(named: "campfire"), UIImage(named: "cool"), UIImage(named: "donut"), UIImage(named: "dream-big"), UIImage(named: "fried-chicken"), UIImage(named: "haha"), UIImage(named: "happy-face"), UIImage(named: "hot"), UIImage(named: "ice-cream"), UIImage(named: "lol"), UIImage(named: "popsicle"), UIImage(named: "bicycle"), UIImage(named: "bouquet")]
    
    //UIImage.gif(name: "corazon"), UIImage.gif(name: "thanks"), UIImage.gif(name: "animated-text"), UIImage.gif(name: "yay"), UIImage.gif(name: "bomb-joypixels"), UIImage.gif(name: "colin-raff-grotesque"), UIImage.gif(name: "stars"), UIImage.gif(name: "ice-cream-helado"), UIImage.gif(name: "fullframenl-fullframe"), UIImage.gif(name: "eyes-noto-color-emoji"), UIImage.gif(name: "butterfly-blue"), UIImage.gif(name: "cute-kawaii")
    
    var onSelectSticker: ((UIImage)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onBackBtn(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

extension StickersVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickersCollectionViewCell", for: indexPath) as? StickersCollectionViewCell else { return UICollectionViewCell() }
        cell.stickerImgView.image = stickers[indexPath.row]
        cell.stickerImgView.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (SCREENWIDTH()-90)/4, height: (SCREENWIDTH()-90)/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let img = stickers[indexPath.row] {
            onSelectSticker?(img)
        }
    }
}
