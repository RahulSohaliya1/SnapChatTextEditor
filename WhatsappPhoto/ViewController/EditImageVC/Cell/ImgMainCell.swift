//
//  ImgMainCell.swift
//  WhatsappPhoto
//
//  Created by PC on 23/09/22.
//

import UIKit

//protocol ModesDeletegate {
//    var currentMode: Mode? { get set }
//    func undoClick(currentMode: Mode)
//}

class ImgMainCell: UICollectionViewCell {
    
    @IBOutlet weak var canvasView: UIView!
    //To hold the image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    //To hold the drawings and stickers
    @IBOutlet weak var canvasImageView: UIImageView!
    
    var currentMode: Mode? {
        didSet {
            self.checkMode()
        }
    }
    var drawColor: UIColor = UIColor.red
    var drawEmoji: String = "😃"
    var isDrawing: Bool = false
    var isEmojiDrawing: Bool = false
    var lastPoint: CGPoint!
    var swiped = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        canvasImageView.image = nil
        canvasView = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isDrawing = true
        isEmojiDrawing = true
        canvasImageView.isUserInteractionEnabled = false
    }
    
    func checkMode() {
        
        if currentMode == .emojiDrawMode {
            print("emoji draw")
        }
        
        if currentMode == .drawMode {
            print("drow")
        }
        
        if currentMode == .textMode {
            print("Text")
        }
    }
    
    func undoClick(currentMode: Mode) {
        
        if currentMode == .emojiDrawMode {
            DispatchQueue.main.async {
                self.canvasImageView.image = UIImage()
                self.canvasImageView.setNeedsDisplay()
            }
        }
        
        print("undo")
        if currentMode == .drawMode {
            DispatchQueue.main.async {
                self.canvasImageView.image = UIImage()
                self.canvasImageView.setNeedsDisplay()
            }
        }
        
        if currentMode == .textMode {
            for subview in canvasImageView.subviews {
                subview.removeFromSuperview()
            }
        }
    }
    
    func setImage(image: UIImage) {
        imageView.image = image
        let size = image.suitableSize(widthLimit: UIScreen.main.bounds.width)
        imageViewHeightConstraint.constant = (size?.height)!
    }
    
    func setModel(vc: EditImageVC) {
        //        vc.modeDelegate = self
    }
    
    //    //clear drawing
    //    canvasImageView.image = nil
    //    //clear stickers and textviews
    //    for subview in canvasImageView.subviews {
    //        subview.removeFromSuperview()
    //    }
}

extension ImgMainCell {
    
    override public func touchesBegan(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            swiped = false
            if let touch = touches.first {
                lastPoint = touch.location(in: self.canvasImageView)
            }
        }
        
        if isEmojiDrawing {
            swiped = false
            if let touch = touches.first {
                lastPoint = touch.location(in: self.canvasImageView)
            }
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            // 6
            swiped = true
            if let touch = touches.first {
                let currentPoint = touch.location(in: canvasImageView)
                drawLineFrom(lastPoint, toPoint: currentPoint)
                // 7
                lastPoint = currentPoint
            }
        }
        
        if isEmojiDrawing {
            // 6
            swiped = true
            if let touch = touches.first {
                let currentPoint = touch.location(in: canvasImageView)
                drawEmojiFrom(lastPoint, toPoint: currentPoint)
                // 7
                lastPoint = currentPoint
            }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            if !swiped {
                // draw a single point
                drawLineFrom(lastPoint, toPoint: lastPoint)
            }
        }
        
        if isEmojiDrawing {
            if !swiped {
                // draw a single point
                drawEmojiFrom(lastPoint, toPoint: lastPoint)
            }
        }
    }
    
    
    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        // 1
        let canvasSize = canvasImageView.frame.integral.size
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            canvasImageView.image?.draw(in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height))
            // 2
            context.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
            context.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
            // 3
            context.setLineCap( CGLineCap.round)
            context.setLineWidth(4.0)
            context.setStrokeColor(drawColor.cgColor)
            context.setBlendMode( CGBlendMode.normal)
            // 4
            context.strokePath()
            // 5
            canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
    }
    
    func drawEmojiFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        let canvasSize = canvasImageView.frame.integral.size
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0)
        if UIGraphicsGetCurrentContext() != nil {
            canvasImageView.image?.draw(in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height))
            // Draw emoji at the midpoint between fromPoint and toPoint
            let emojiSize: CGFloat = 24 // Adjust the size of the emoji as needed
            let midpoint = CGPoint(x: (fromPoint.x + toPoint.x) / 2, y: (fromPoint.y + toPoint.y) / 2)
            let font = UIFont.systemFont(ofSize: emojiSize)
            let attributes = [NSAttributedString.Key.font: font]
            let attributedString = NSAttributedString(string: drawEmoji, attributes: attributes)
            let textSize = attributedString.size()
            let rect = CGRect(x: midpoint.x - textSize.width / 2, y: midpoint.y - textSize.height / 2, width: textSize.width, height: textSize.height)
            attributedString.draw(in: rect)
            // Update canvas image
            canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
    }
}


