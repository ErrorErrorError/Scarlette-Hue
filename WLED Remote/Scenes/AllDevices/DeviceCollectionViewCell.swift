//
//  DeviceCell.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/13/21.
//

import UIKit

class DeviceCollectionViewCell: UICollectionViewCell {
    static var identifier = "device-cell"

    let textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    let lightSwitch: UISwitch = {
        let switchs = UISwitch(frame: .zero)
        switchs.onTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        switchs.tintColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)
        switchs.layer.cornerRadius = 16
        return switchs
    }()

    let brightnessSlider: BrightnessSlider = {
        let slider = BrightnessSlider(frame: .zero)
        slider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return slider
    }()

    let animatableStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let inset: CGFloat = 24
        let height: CGFloat = 30

        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = height / 2
        clipsToBounds = true

        let deviceInfoStackView = UIStackView(arrangedSubviews: [textLabel, lightSwitch])
        deviceInfoStackView.spacing = inset
        deviceInfoStackView.distribution = .fill
        deviceInfoStackView.alignment = .center
        deviceInfoStackView.isLayoutMarginsRelativeArrangement = true
        deviceInfoStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: inset, bottom: 16, trailing: inset)

        animatableStackView.addArrangedSubview(deviceInfoStackView)
        animatableStackView.addArrangedSubview(brightnessSlider)

        contentView.addSubview(animatableStackView)

        animatableStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        animatableStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        animatableStackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        animatableStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        lightSwitch.addTarget(self, action: #selector(handleToggle), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func handleToggle() {
        UIView.animate(withDuration: 0.25) { [unowned self] in
            self.brightnessSlider.isHidden = !self.lightSwitch.isOn
            self.animatableStackView.setNeedsLayout()
            (self.superview as? UICollectionView)?.setNeedsLayout()
            self.animatableStackView.layoutIfNeeded()
            (self.superview as? UICollectionView)?.collectionViewLayout.invalidateLayout()
            (self.superview as? UICollectionView)?.layoutIfNeeded()
        }
    }

    func configure(_ data: Device) {
        textLabel.text = data.name

        if let state = data.state {
            let enabled = state.on == true
            brightnessSlider.isHidden = !enabled
            brightnessSlider.value = Float(state.bri ?? 127)
            lightSwitch.isOn = enabled
            brightnessSlider.isEnabled = true
            lightSwitch.isEnabled = true
            lightSwitch.backgroundColor = !enabled ? nil : UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)

        } else {
            brightnessSlider.isHidden = true
            brightnessSlider.isEnabled = false
            lightSwitch.isOn = false
            lightSwitch.isEnabled = false
        }
    }

    private func getFirstSelectedSegment(state: State) -> Segment? {
        if let segments = state.segments {
            if let segment = segments.first(where: { $0.selected == true }) {
                return segment
            } else if let segment = segments.first {
                return segment
            }
        }
        return nil
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}
