//
//  ImgListCell.swift
//  WhatsappPhoto
//
//  Created by PC on 22/09/22.
//

import UIKit

class ImgListCell: UICollectionViewCell {
    
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        viewImage.layer.cornerRadius = 5
    }
    
    func setSelectedImage(isSelected: Bool) {
        if isSelected {
            viewImage.layer.borderColor = UIColor(hex: "1AD191").cgColor
            viewImage.layer.borderWidth = UIScreen.main.bounds.width * 2 / 375
        } else {
            viewImage.layer.borderColor = UIColor.clear.cgColor
            viewImage.layer.borderWidth = 0
        }
    }
    
    @IBAction func onBtnImageSelect(_ sender: Any) { }
    
}
