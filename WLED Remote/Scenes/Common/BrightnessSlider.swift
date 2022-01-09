//
//  BrightnessSlider.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/13/21.
//

import UIKit

// TODO: Create own UISlider with background semi transparent kind of like the switch

class BrightnessSlider: UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
        minimumValue = 1
        maximumValue = 255

        updateTracks()
//        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
//        layer.bounds.size.height -= 1.5
//        layer.masksToBounds = true
//        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateTracks()
        layer.cornerRadius = bounds.height / 2
    }

    override func setValue(_ value: Float, animated: Bool) {
        super.setValue(value, animated: animated)
        updateTracks()
    }

    func updateTracks() {
        let minImage = minTrackImageGradient()
        let maxImage = maxTrackImageGenerate()
        self.setMinimumTrackImage(minImage, for: .normal)
        self.setMaximumTrackImage(maxImage, for: .normal)
    }

    private func createThumb() -> UIImage {
        let size = bounds.height
        let rect = CGRect(x: 0, y: 0, width: size, height: size)

        let renderer = UIGraphicsImageRenderer(bounds: rect)

        let image = renderer.image { ctx in
            ctx.cgContext.setShadow(offset: CGSize(width: 20, height: 20), blur: 20)
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fillEllipse(in: rect)
        }
        return image
    }

    let inset: CGFloat = 2
    let offset: CGFloat = -0.5

    private func minTrackImageGradient() -> UIImage {
        let trackRect = bounds
        let thumbRect = thumbRect(forBounds: bounds, trackRect: trackRect, value: self.value)

        let drawBounds = CGRect(x: 0, y: 0, width: trackRect.width, height: thumbRect.height)
        let renderer = UIGraphicsImageRenderer(bounds: drawBounds)
        let bezier = UIBezierPath(roundedRect: drawBounds.insetBy(dx: 0, dy: inset).offsetBy(dx: 0, dy: offset), byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: drawBounds.width, height: drawBounds.height))
        let image = renderer.image { ctx in
            ctx.cgContext.addPath(bezier.cgPath)
            ctx.cgContext.clip()
            UIColor.white.setFill()
            ctx.fill(drawBounds)
        }

        return image
    }

    private func maxTrackImageGenerate() -> UIImage {
        let maxTrackColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)

        let trackRect = bounds
        let thumbRect = thumbRect(forBounds: bounds, trackRect: trackRect, value: self.value)

        let drawBounds = CGRect(x: 0, y: 0, width: trackRect.width, height: thumbRect.height)
        let renderer = UIGraphicsImageRenderer(bounds: drawBounds)

        let bezier = UIBezierPath(roundedRect: drawBounds.insetBy(dx: 0, dy: inset).offsetBy(dx: 0, dy: offset), byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: drawBounds.width, height: drawBounds.height))
        let image = renderer.image { ctx in
            ctx.cgContext.addPath(bezier.cgPath)
            ctx.cgContext.clip()
            maxTrackColor.setFill()
            ctx.fill(drawBounds)
        }
        return image
    }
}
