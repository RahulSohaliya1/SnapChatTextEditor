//
//  EmojiKnobPreviewVw.swift
//  WhatsappPhoto
//
//  Created by DREAMWORLD on 17/05/24.
//

import Foundation
import UIKit

class CircleView: UIView {
    
    // Emoji property with a default value
    var emoji: String = "♨️" {
        didSet {
            setNeedsDisplay()
        }
    }

    // Initialize with frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    // Initialize with coder (required for storyboard/xib)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // Common setup code
    private func setup() {
        // Add any setup code here
        self.backgroundColor = .clear
    }

    // Custom drawing code
    // Custom drawing code
    override func draw(_ rect: CGRect) {
        // Get the current context
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Clear the context
        context.clear(rect)

        // Adjust the radius to fit the view bounds with the pin tail
        let radius = min(rect.width, rect.height) / 2 - 10

        // Draw the circle outline
        let center = CGPoint(x: rect.midX, y: rect.midY - radius / 3)
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(3.8)
        context.addArc(center: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        context.strokePath()

        // Draw the rounded background for the emoji
        let emojiBackgroundRect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        )
        let emojiBackgroundPath = UIBezierPath(roundedRect: emojiBackgroundRect, cornerRadius: radius)
        context.setFillColor(UIColor.white.cgColor)
        context.addPath(emojiBackgroundPath.cgPath)
        context.fillPath()

        // Save the current context state
        context.saveGState()

        // Move the context's origin to the center of the emoji and rotate it
        context.translateBy(x: center.x, y: center.y)
        context.rotate(by: CGFloat.pi / 2)
        context.translateBy(x: -center.x, y: -center.y)

        // Draw the emoji
        let emojiAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: radius * 1.5) // Adjust the font size based on the radius
        ]
        let attributedEmoji = NSAttributedString(string: emoji, attributes: emojiAttributes)
        let emojiSize = attributedEmoji.size()
        let emojiRect = CGRect(
            x: center.x - emojiSize.width / 2,
            y: center.y - emojiSize.height / 2,
            width: emojiSize.width,
            height: emojiSize.height
        )
        attributedEmoji.draw(in: emojiRect)

        // Restore the context state
        context.restoreGState()

        // Draw the pin tail
        context.setFillColor(UIColor.white.cgColor)
        let tailPath = UIBezierPath()
        tailPath.move(to: CGPoint(x: rect.midX - 8, y: center.y + radius))
        tailPath.addLine(to: CGPoint(x: rect.midX + 8, y: center.y + radius))
        tailPath.addLine(to: CGPoint(x: rect.midX, y: center.y + radius + 10))  // Adjusted length of tail
        tailPath.close()
        context.addPath(tailPath.cgPath)
        context.fillPath()
    }
}
