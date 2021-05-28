//
//  DeviceCell.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/13/21.
//

import UIKit
import RxSwift
import RxCocoa

class DeviceCollectionViewCell: UICollectionViewCell {
    static var identifier = "device-cell"

    // MARK: Rx

    private var dispose = DisposeBag()

    let nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "WLED"
        return label
    }()

    let connectionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.text = "Connecting"
        return label
    }()

    let lightSwitch: UISwitch = {
        let switchs = UISwitch(frame: .zero)
        switchs.onTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.20)
        switchs.tintColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)
        switchs.layer.cornerRadius = 16
        switchs.isOn = false
        switchs.isEnabled = false
        return switchs
    }()

    let brightnessSlider: BrightnessSlider = {
        let slider = BrightnessSlider(frame: .zero)
        slider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        slider.isHidden = true
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

    override public class var layerClass: Swift.AnyClass {
        get {
            return CAGradientLayer.self
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let cornerRadius: CGFloat = 30 / 2
        backgroundColor = .contentOverSystembackground

        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.cornerCurve = .circular

        layer.shadowRadius = 8.0
        layer.shadowOpacity = 0.10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)

        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        let inset: CGFloat = 24

        let deviceInfoStackView = UIStackView(arrangedSubviews: [nameLabel, connectionLabel])
        deviceInfoStackView.distribution = .fill
        deviceInfoStackView.alignment = .leading
        deviceInfoStackView.axis = .vertical
        deviceInfoStackView.spacing = 2

        let deviceStateStackView = UIStackView(arrangedSubviews: [deviceInfoStackView, lightSwitch])
        deviceStateStackView.spacing = inset
        deviceStateStackView.distribution = .fill
        deviceStateStackView.alignment = .center
        deviceStateStackView.isLayoutMarginsRelativeArrangement = true
        deviceStateStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: inset, bottom: 20, trailing: inset)

        animatableStackView.addArrangedSubview(deviceStateStackView)
        animatableStackView.addArrangedSubview(brightnessSlider)

        contentView.addSubview(animatableStackView)

        animatableStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        animatableStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        animatableStackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        animatableStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    @objc func animateSwitchBrightness() {
        UIView.animate(withDuration: 0.25) { [unowned self] in
            self.brightnessSlider.isHidden = !self.lightSwitch.isOn
            resizeView()
        }
    }

    override func prepareForReuse() {
        dispose = DisposeBag()
        lightSwitch.isOn = false
        lightSwitch.isEnabled = false
        nameLabel.textColor = .label
        connectionLabel.textColor = .secondaryLabel
        resizeView()
    }

    func bind(_ viewModel: DeviceItemViewModel) {
        self.nameLabel.text = viewModel.name

        let input = DeviceItemViewModel.Input(heartbeat: Driver.empty(),
                                              on: lightSwitch.rx.value.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input: input)
        output.heartbeat.drive().disposed(by: dispose)
        output.connection.drive(connectionLabel.rx.text).disposed(by: dispose)
        output.state.drive(stateBinding).disposed(by: dispose)
        output.update.drive().disposed(by: dispose)
    }

    private var stateBinding: Binder<State?> {
        return Binder(self) { cell, state in
            var colors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
            var deviceNameTextColor = UIColor.label
            var connectionTextColor = UIColor.secondaryLabel

            let gradientLayer = cell.layer as! CAGradientLayer
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

            // MARK: set state
            if let state = state {
                let enabled = state.on == true
                cell.lightSwitch.isEnabled = true
                cell.lightSwitch.backgroundColor = !enabled ? nil : UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.20)
                cell.brightnessSlider.value = Float(state.bri ?? 127)
                cell.lightSwitch.isOn = enabled
            } else {
                cell.lightSwitch.isEnabled = false
                cell.lightSwitch.isOn = false
            }

            cell.resizeView()

            if state?.on == true, let segment = state?.firstSegment {
                let primary = segment.colors[0]
                let secondary = segment.colors[1]
                let tertiary = segment.colors[2]

                var newColors = [primary, secondary, tertiary]
                    .filter({ $0.reduce(0, +) != 0 })
                    .map({ UIColor(red: $0[0], green: $0[1], blue: $0[2]).cgColor })

                if newColors.count == 1 {
                    newColors.append(newColors[0])
                }

                colors = newColors

                if let first = newColors.first {
                    let color = UIColor(cgColor: first)
                    deviceNameTextColor = color.isLight ? .black : .white
                    connectionTextColor = color.isLight ?  .init(red: 0.1,
                                                                 green: 0.1,
                                                                 blue: 0.1,
                                                                 alpha: 1.0) : .init(red: 0.9,
                                                                                     green: 0.9,
                                                                                     blue: 0.9,
                                                                                     alpha: 1.0)
                }
            }

            cell.nameLabel.textColor = deviceNameTextColor
            cell.connectionLabel.textColor = connectionTextColor

            gradientLayer.changeGradients(colors, animate: true)
        }
    }

    private func resizeView() {
        self.animatableStackView.setNeedsLayout()
        self.animatableStackView.layoutIfNeeded()
        if let superview = self.superview as? UICollectionView {
            superview.setNeedsLayout()
            superview.collectionViewLayout.invalidateLayout()
            superview.layoutIfNeeded()
        }
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize,
                                                                          withHorizontalFittingPriority: .required,
                                                                          verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}

// MARK: Animation on highlight
extension DeviceCollectionViewCell {
    override var isHighlighted: Bool {
        didSet { shrink(down: isHighlighted) }
    }

    func shrink(down: Bool) {
        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.8,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: { self.transform = down ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity },
            completion: nil)

    }
}

extension CAGradientLayer {
    func changeGradients(_ newColors: [CGColor]? = nil, _ location: [NSNumber]? = nil, animate: Bool) {
        // MARK: Animate color changed
        let gradientAnimation = CABasicAnimation(keyPath: "colors")
        if self.colors == nil {
            self.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
        }
        gradientAnimation.fromValue = self.colors
        gradientAnimation.toValue = newColors
        gradientAnimation.duration = 0.25
        gradientAnimation.isRemovedOnCompletion = true
        gradientAnimation.fillMode = .forwards

        self.colors = newColors
        self.add(gradientAnimation, forKey: nil)
    }
}
