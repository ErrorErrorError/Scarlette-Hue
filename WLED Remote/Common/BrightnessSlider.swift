//
//  BrightnessSlider.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/13/21.
//

import UIKit

class BrightnessSlider: UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
        minimumValue = 1
        maximumValue = 255

        updateTracks()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
//        let thumb = createThumb()
//        self.setThumbImage(thumb, for: .normal)
        updateTracks()
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
            ctx.cgContext.saveGState()
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fillEllipse(in: rect)
            ctx.cgContext.restoreGState()
        }
        return image
    }

    private func minTrackImageGradient() -> UIImage {
        let minTrackStartColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.2)
        let minTrackEndColor = UIColor.white

        let trackRect = bounds
        let thumbRect = thumbRect(forBounds: bounds, trackRect: trackRect, value: self.value)

        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: thumbRect.origin.x + (thumbRect.width / 2) + 3.0, height: thumbRect.height)
        gradient.colors = [minTrackStartColor.cgColor, minTrackEndColor.cgColor]
        gradient.masksToBounds = true
        gradient.type = .axial
        gradient.locations = [0.0, 0.90]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)

        let renderer = UIGraphicsImageRenderer(size: trackRect.size)
        let image = renderer.image { ctx in
            gradient.render(in: ctx.cgContext)
        }

        return image
    }

    private func maxTrackImageGenerate() -> UIImage {
        let maxTrackColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)

        let trackRect = bounds
        let thumbRect = thumbRect(forBounds: bounds, trackRect: trackRect, value: self.value)

        let drawBounds = CGRect(x: 0, y: 0, width: trackRect.size.width - thumbRect.origin.x, height: thumbRect.height)
        let renderer = UIGraphicsImageRenderer(bounds: drawBounds)
        let image = renderer.image { ctx in
            maxTrackColor.setFill()
            ctx.fill(drawBounds)
        }
        return image
    }
}
