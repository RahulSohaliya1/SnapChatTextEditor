//
//  EditImageVC+Gestures.swift
//  WhatsappPhoto
//
//  Created by PC on 26/09/22.
//

import Foundation
import UIKit

extension EditImageVC : UIGestureRecognizerDelegate  {
    
    /**
     UIPanGestureRecognizer - Moving Objects
     Selecting transparent parts of the imageview won't move the object
     */
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        if let view = recognizer.view {
            if view is UIImageView {
                //Tap only on visible parts on the image
                if recognizer.state == .began {
                    if arrEditPhoto[0].isPhoto {
                        for imageView in subImageViews(view: imageView) {
                            let location = recognizer.location(in: imageView)
                            let alpha = imageView.alphaAtPoint(location)
                            if alpha > 0 {
                                imageViewToPan = imageView
                                break
                            }
                        }
                    } else {
                        for imageView in subImageViews(view: canvasImageView) {
                            let location = recognizer.location(in: imageView)
                            let alpha = imageView.alphaAtPoint(location)
                            if alpha > 0 {
                                imageViewToPan = imageView
                                break
                            }
                        }
                    }
                }
                if imageViewToPan != nil {
                    moveView(view: imageViewToPan!, recognizer: recognizer)
                }
            } else {
                moveView(view: view, recognizer: recognizer)
            }
        }
    }
    
    /**
     UIPinchGestureRecognizer - Pinching Objects
     If it's a UITextView will make the font bigger so it doen't look pixlated
     */
    @objc func pinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            if view is UITextView {
                let textView = view as! UITextView
                
                if textView.font!.pointSize * recognizer.scale < 90 {
                    let font = UIFont(name: textView.font!.fontName, size: textView.font!.pointSize * recognizer.scale)
                    textView.font = font
                    let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                                 height:CGFloat.greatestFiniteMagnitude))
                    textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                                  height: sizeToFit.height)
                } else {
                    let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                                 height:CGFloat.greatestFiniteMagnitude))
                    textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                                  height: sizeToFit.height)
                }
                
                
                textView.setNeedsDisplay()
            } else {
                view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            }
            recognizer.scale = 1
        }
    }
    
    /**
     UIRotationGestureRecognizer - Rotating Objects
     */
    @objc func rotationGesture(_ recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    /**
     UITapGestureRecognizer - Taping on Objects
     Will make scale scale Effect
     Selecting transparent parts of the imageview won't move the object
     */
    @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
        if let view = recognizer.view {
            if view is UIImageView {
                if arrEditPhoto[0].isPhoto {
                    //Tap only on visible parts on the image
                    for imageView in subImageViews(view: imageView) {
                        let location = recognizer.location(in: imageView)
                        let alpha = imageView.alphaAtPoint(location)
                        if alpha > 0 {
                            scaleEffect(view: imageView)
                            break
                        }
                    }
                } else {
                    //Tap only on visible parts on the image
                    for imageView in subImageViews(view: canvasImageView) {
                        let location = recognizer.location(in: imageView)
                        let alpha = imageView.alphaAtPoint(location)
                        if alpha > 0 {
                            scaleEffect(view: imageView)
                            break
                        }
                    }
                }
            } else {
                scaleEffect(view: view)
            }
        }
    }
    
    /*
     Support Multiple Gesture at the same time
     */
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    //    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
    //        if recognizer.state == .recognized {
    //            if !stickersVCIsVisible {
    //                addStickersViewController()
    //            }
    //        }
    //    }
    
    // to Override Control Center screen edge pan from bottom
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    /**
     Scale Effect
     */
    func scaleEffect(view: UIView) {
        view.superview?.bringSubviewToFront(view)
        
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        let previouTransform =  view.transform
        UIView.animate(withDuration: 0.2,
                       animations: {
            view.transform = view.transform.scaledBy(x: 1.2, y: 1.2)
        },
                       completion: { _ in
            UIView.animate(withDuration: 0.2) {
                view.transform  = previouTransform
            }
        })
    }
    
    /**
     Moving Objects
     delete the view if it's inside the delete view
     Snap the view back if it's out of the canvas
     */
    
    func moveView(view: UIView, recognizer: UIPanGestureRecognizer)  {
        
        deleteView.isHidden = false
        btnDoneImg.isHidden = false
        editingOptions.isHidden = true
        
        view.superview?.bringSubviewToFront(view)
        let pointToSuperView = recognizer.location(in: self.view)
        
        if arrEditPhoto[0].isPhoto {
            view.center = CGPoint(x: view.center.x + recognizer.translation(in: imageView).x,
                                  y: view.center.y + recognizer.translation(in: imageView).y)
            
            recognizer.setTranslation(CGPoint.zero, in: imageView)
        } else {
            view.center = CGPoint(x: view.center.x + recognizer.translation(in: canvasImageView).x,
                                  y: view.center.y + recognizer.translation(in: canvasImageView).y)
            
            recognizer.setTranslation(CGPoint.zero, in: canvasImageView)
        }
        
        if let previousPoint = lastPanPoint {
            //View is going into deleteView
            if deleteView.frame.contains(pointToSuperView) && !deleteView.frame.contains(previousPoint) {
                if #available(iOS 10.0, *) {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                }
                UIView.animate(withDuration: 0.3, animations: {
                    view.transform = view.transform.scaledBy(x: 0.25, y: 0.25)
                    if self.arrEditPhoto[0].isPhoto {
                        view.center = recognizer.location(in: self.imageView)
                    } else {
                        view.center = recognizer.location(in: self.canvasImageView)
                    }
                })
            }
            //View is going out of deleteView
            else if deleteView.frame.contains(previousPoint) && !deleteView.frame.contains(pointToSuperView) {
                //Scale to original Size
                UIView.animate(withDuration: 0.3, animations: {
                    view.transform = view.transform.scaledBy(x: 4, y: 4)
                    if self.arrEditPhoto[0].isPhoto {
                        view.center = recognizer.location(in: self.imageView)
                    } else {
                        view.center = recognizer.location(in: self.canvasImageView)
                    }
                })
            }
        }
        lastPanPoint = pointToSuperView
        
        if recognizer.state == .ended {
            imageViewToPan = nil
            lastPanPoint = nil
            deleteView.isHidden = true
            btnDoneImg.isHidden = false
            editingOptions.isHidden = false
            let point = recognizer.location(in: self.view)
            
            if deleteView.frame.contains(point) { // Delete the view
                view.removeFromSuperview()
                urlPreviewView = nil
                if #available(iOS 10.0, *) {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
                
                if view == activeTextView {
                    isTextViewAdded = false
                }
                
            } else {
                if arrEditPhoto[0].isPhoto {
                    if !imageView.bounds.contains(view.center) { //Snap the view back to canvasImageView
                        UIView.animate(withDuration: 0.3, animations: {
                            print(self.imageView.center)
                            print(view.center)
                            view.center = self.imageView.center
                        })
                        
                    }
                } else {
                    if !canvasImageView.bounds.contains(view.center) { //Snap the view back to canvasImageView
                        UIView.animate(withDuration: 0.3, animations: {
                            print(self.canvasImageView.center)
                            print(view.center)
                            view.center = self.canvasImageView.center
                        })
                    }
                }
            }
        }
    }
    
    func subImageViews(view: UIView) -> [UIImageView] {
        var imageviews: [UIImageView] = []
        for imageView in view.subviews {
            if imageView is UIImageView {
                imageviews.append(imageView as! UIImageView)
            }
        }
        return imageviews
    }
}
