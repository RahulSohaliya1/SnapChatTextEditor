//
//  EditImageVC+Text.swift
//  WhatsappPhoto
//
//  Created by PC on 26/09/22.
//

import Foundation
import UIKit
import IMITextView

extension EditImageVC {
    
    func setupTextFeild() {
        guard !isTextViewAdded else { return }
         
         let textView = IMITextView()
         
         textView.translatesAutoresizingMaskIntoConstraints = false
         textView.textView.delegate = self
         //        textView.configuration.lineBackgroundOptions = .fill
         textView.configuration.textAlignment = .center
         textView.configuration.strokeColor = .systemRed
         textView.configuration.font = UIFont(name: "AmericanTypewriter", size: 30)!
         textView.configuration.textColor = textViewTextColor
         //        textView.configuration.lineBackgroundColor = textViewTextColor
         textView.configuration.lineBoderColor = textViewTextColor
         activeTextView = textView
         lastTextViewFont = textView.configuration.font
            
         textView.layer.shadowColor = UIColor.black.cgColor
         textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
         textView.layer.shadowOpacity = 0.2
         textView.layer.shadowRadius = 1.0
         textView.layer.backgroundColor = UIColor.clear.cgColor
         textView.isScrollEnabled = false
         textView.delegate = self
         if arrEditPhoto[0].isPhoto {
             self.imageView.addSubview(textView)
             if imageView.superview == nil {
                 self.view.addSubview(imageView)
             }
             
             NSLayoutConstraint.activate([
                      // Center the textView horizontally within the canvasImageView
                      textView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                      // Set the width of the textView
                      textView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
                      // Position the bottom of textView 20 points above the top of clvTextPicker
                      textView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
                  ])
             
         } else {
             self.canvasImageView.addSubview(textView)
             if canvasImageView.superview == nil {
                 self.view.addSubview(canvasImageView)
             }

             NSLayoutConstraint.activate([
                      textView.centerXAnchor.constraint(equalTo: canvasImageView.centerXAnchor),
                      textView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
                      textView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
                  ])
         }
         
         addGestures(view: textView)
         textView.becomeFirstResponder()
        isTextViewAdded = true
     }
    
    func addGestures(view: UIView) {
        //Gestures
        view.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(EditImageVC.panGesture))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(EditImageVC.pinchGesture))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                    action:#selector(EditImageVC.rotationGesture) )
        rotationGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotationGestureRecognizer)
        
        // Check if urlPreviewView is visible
           if urlPreviewView?.isHidden == false {
               let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
               view.addGestureRecognizer(tapGesture)
           }
    }
}
