//
//  EditImageVC+Draw.swift
//  WhatsappPhoto
//
//  Created by PC on 26/09/22.
//

import Foundation
import UIKit

extension EditImageVC {
    
    override public func touchesBegan(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            UIView.animate(withDuration: 0.3) {
                self.editingOptions.alpha = 0
                self.editingOptions.isHidden = true
                self.btnUndo.isHidden = true
                self.btnUndo.alpha = 0
            }
            swiped = false
            if let touch = touches.first {
                lastPoint = touch.location(in: self.canvasImageView)
                print("touchesBegan",lastPoint)
                arrLinesModel.append(.init(point: [lastPoint], color: [drawColor]))
            }
        }
        
        if isEmojiDrawing {
            swiped = false
            UIView.animate(withDuration: 0.3) {
                self.editingOptions.alpha = 0
                self.editingOptions.isHidden = true
                self.btnUndo.isHidden = true
                self.btnUndo.alpha = 0
            }
            if let touch = touches.first {
                lastEmojiPoint = touch.location(in: self.canvasImageView)
                print("touchesBeganEmoji", lastEmojiPoint)
                arrEmojiModel.append(.init(points: [lastEmojiPoint], emojis: [drawEmoji]))
            }
            
        }
        if arrEditPhoto[0].isPhoto {
            self.view.endEditing(true)
            if currentMode == .textMode {
                clvTextPicker.isHidden = true
                btnDraw.isHidden = false
                btnUndo.isHidden = true
                btnTextAlignment.isHidden = true
                btnAlternateStyle.isHidden = true
                btnStrokeColor.isHidden = true
                btnHeartEyesEmoji.isHidden = true
                colorSlider.isHidden = true
                canvasImageView.isUserInteractionEnabled = false
                imageView.isUserInteractionEnabled = true
                btnTextAdd.isSelected = false
                isTyping = false
                btnDoneImg.isHidden = false
                hideToolbar(hide: false)
                currentMode = .none
                activeTextView?.resignFirstResponder()
                view.endEditing(true)
                //save
                if let tv = self.canvasImageView.subviews as? [UITextView] {
                    self.arrEditPhoto[selectedImageIndex].textViews = tv
                }
                self.arrEditPhoto[selectedImageIndex].doneImage = canvasView.toImage()
            }
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            UIView.animate(withDuration: 0.3) {
                self.editingOptions.alpha = 0
                self.editingOptions.isHidden = true
                self.btnUndo.isHidden = true
                self.btnUndo.alpha = 0
            }
            // 6
            swiped = true
            if let touch = touches.first {
                let currentPoint = touch.location(in: canvasImageView)
                
                let lastLine1 = arrLinesModel.removeLast()
                guard var points = lastLine1.point, var colors = lastLine1.color else { return }
                points.append(currentPoint)
                colors.append(self.drawColor)
                arrLinesModel.append(PointModel(point: points, color: colors))
                
                DispatchQueue.main.async {
                    self.drawLineFrom()
                }
                // 7
                lastPoint = currentPoint
            }
        }
        
        if isEmojiDrawing {
            swiped = true
            UIView.animate(withDuration: 0.3) {
                self.editingOptions.alpha = 0
                self.editingOptions.isHidden = true
                self.btnUndo.isHidden = true
                self.btnUndo.alpha = 0
            }
            if let touch = touches.first {
                let currentPoint = touch.location(in: canvasImageView)
                
                let distance = hypot(currentPoint.x - lastEmojiPoint.x, currentPoint.y - lastEmojiPoint.y)
                
                if distance > minimumDistance {
                    let lastLine2 = arrEmojiModel.removeLast()
                    guard var points = lastLine2.points, var emojis = lastLine2.emojis else { return }
                    points.append(currentPoint)
                    emojis.append(self.drawEmoji)
                    arrEmojiModel.append(PointEmojiModel(points: points, emojis: emojis))
                    
                    DispatchQueue.main.async {
                        self.drawEmojiFrom()
                    }
                    
                    lastEmojiPoint = currentPoint
                }
            }
            
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            UIView.animate(withDuration: 0.3) {
                self.editingOptions.alpha = 1
                self.editingOptions.isHidden = false
                self.btnUndo.isHidden = false
                self.btnUndo.alpha = 1
            }
            if !swiped {
                // draw a single point
                DispatchQueue.main.async {
                    self.drawLineFrom(self.lastPoint, toPoint: self.lastPoint)
                }
            }
        }
        
        if isEmojiDrawing {
            UIView.animate(withDuration: 0.3) {
                self.editingOptions.alpha = 1
                self.editingOptions.isHidden = false
                self.btnUndo.isHidden = false
                self.btnUndo.alpha = 1
            }
            if !swiped {
                DispatchQueue.main.async {
                    self.drawEmojiFrom(self.lastEmojiPoint, toPoint: self.lastEmojiPoint)
                }
            }
        }
    }
    
    func drawLineFrom(_ fromPoint: CGPoint = CGPoint.zero, toPoint: CGPoint = CGPoint.zero) {
        // 1
        let canvasSize = canvasImageView.frame.integral.size
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        canvasImageView.image?.draw(in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height))
        
        context.setLineCap(CGLineCap.round)
        context.setLineWidth(4.0)
        context.setBlendMode(CGBlendMode.normal)
        
        for i in arrLinesModel {
            guard let point = i.point, let color = i.color else { return }
            for (indx,j) in point.enumerated() {
                if indx == 0 {
                    context.move(to: j)
                    context.setStrokeColor(color[indx].cgColor)
                } else {
                    context.addLine(to: j)
                    context.setStrokeColor(color[indx].cgColor)
                }
            }
            context.strokePath()
        }
        
        canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        canvasImageView.setNeedsDisplay()
    }
    
    func drawEmojiFrom(_ fromPoint: CGPoint = CGPoint.zero, toPoint: CGPoint = CGPoint.zero) {
        // 1
        let canvasSize = canvasImageView.frame.integral.size
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        canvasImageView.image?.draw(in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height))
        
        context.setLineCap( CGLineCap.round)
        context.setLineWidth(4.0)
        context.setBlendMode( CGBlendMode.normal)
        
        for i in arrEmojiModel {
            guard let points = i.points, let emojis = i.emojis else { continue }
            for (index, point) in points.enumerated() {
                let fontSize: CGFloat = 24
                let font = UIFont.systemFont(ofSize: fontSize)
                let attributes = [NSAttributedString.Key.font: font]
                let attributedString = NSAttributedString(string: emojis[index], attributes: attributes)
                let textSize = attributedString.size()
                let rect = CGRect(x: point.x - textSize.width / 2, y: point.y - textSize.height / 2, width: textSize.width, height: textSize.height)
                attributedString.draw(in: rect)
            }
        }
        
        canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        canvasImageView.setNeedsDisplay()
    }
}
