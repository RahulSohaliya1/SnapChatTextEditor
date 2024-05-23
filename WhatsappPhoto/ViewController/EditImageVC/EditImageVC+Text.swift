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
        
        let textView = IMITextView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        //        textView.configuration.lineBackgroundOptions = .fill
        textView.configuration.textAlignment = .center
        textView.configuration.strokeColor = .systemRed
        textView.configuration.font = UIFont(name: "AmericanTypewriter", size: 30)!
        textView.configuration.textColor = textViewTextColor
        //        textView.configuration.lineBackgroundColor = textViewTextColor
        textView.configuration.lineBoderColor = textViewTextColor
        activeTextView = textView
        lastTextViewFont = textView.configuration.font
        
        //        textView.textAlignment = .center
        //        textView.font = UIFont(name: "AmericanTypewriter", size: 30)
        //        textView.textColor = textViewTextColor
        
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        //        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.delegate = self
        self.canvasImageView.addSubview(textView)
        
        if canvasImageView.superview == nil {
            self.view.addSubview(canvasImageView)
        }
        
        // Add constraints to center the text view
        NSLayoutConstraint.activate([
            //                   textView.centerXAnchor.constraint(equalTo: canvasImageView.centerXAnchor),
            textView.centerYAnchor.constraint(equalTo: canvasImageView.centerYAnchor),
            textView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            //                   textView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        addGestures(view: textView)
        textView.becomeFirstResponder()
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditImageVC.tapGesture))
        view.addGestureRecognizer(tapGesture)
        
    }
}
