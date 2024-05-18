//
//  EditImageVC+Model+Enum.swift
//  WhatsappPhoto
//
//  Created by PC on 10/10/22.
//

import Foundation
import UIKit

enum Mode {
    case none
    case drawMode
    case textMode
    case emojiDrawMode
}

struct EditPhotoModel {
    var isPhoto: Bool = true
    var videoUrl: URL?
    var image: UIImage?
    var lines: [PointModel]?
    var emoji: [PointEmojiModel]?
    var textViews: [UITextView]?
    var doneImage: UIImage?
}

struct PointModel {
    var point: [CGPoint]?
    var color: [UIColor]?
}

struct PointEmojiModel {
    var points: [CGPoint]?
    var emojis: [String]?
}
