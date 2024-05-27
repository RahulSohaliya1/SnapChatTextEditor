//
//  FontPickerCollectionViewCell.swift
//  WhatsappPhoto
//
//  Created by DREAMWORLD on 22/05/24.
//

import UIKit

class FontPickerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var fontStyleLbl: UILabel!
    
    override var isSelected: Bool {
         didSet {
             contentView.backgroundColor = isSelected ? UIColor.white : UIColor.clear
             fontStyleLbl.textColor = isSelected ? UIColor.black : UIColor.white
         }
     }
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
    
}
