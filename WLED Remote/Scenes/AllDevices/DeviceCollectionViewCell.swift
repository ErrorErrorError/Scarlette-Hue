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
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.text = "Connecting"
        return label
    }()

    let lightSwitch: UISwitch = {
        let switchs = UISwitch(frame: .zero)
        switchs.onTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
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

        let height: CGFloat = 30

        backgroundColor = .contentOverSystembackground
        layer.cornerRadius = height / 2
        clipsToBounds = true

        setupConstraints()

        lightSwitch.rx.isOn.asDriver().skip(1).drive(onNext: { _ in self.animateSwitchBrightness() }).disposed(by: dispose)
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
        deviceStateStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: inset, bottom: 16, trailing: inset)

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
        lightSwitch.rx.isOn.asDriver().drive(onNext: { _ in self.animateSwitchBrightness() }).disposed(by: dispose)
        lightSwitch.isOn = false
        lightSwitch.isEnabled = false
        brightnessSlider.isEnabled = false
        brightnessSlider.isHidden = true
        resizeView()
    }

    func bind(_ viewModel: DeviceItemViewModel) {
        self.nameLabel.text = viewModel.name

        let input = DeviceItemViewModel.Input(heartbeat: Driver.empty(),
                                              brightness: brightnessSlider.rx.value.asDriver()
                                                .debounce(.milliseconds(250))
                                                .map({ Int($0) }),
                                              on: lightSwitch.rx.value.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input: input)
        output.heartbeat.drive().disposed(by: dispose)
        output.connection.drive(connectionLabel.rx.text).disposed(by: dispose)
        output.state.drive(stateBinding).disposed(by: dispose)
        output.update.drive().disposed(by: dispose)
    }

    private var stateBinding: Binder<State?> {
        return Binder(self) { cell, state in
            let gradientLayer = cell.layer as! CAGradientLayer
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

            // MARK: Animate color changed
            let gradientAnimation = CABasicAnimation(keyPath: "colors")
            gradientAnimation.fromValue = gradientLayer.colors ?? [UIColor.clear.cgColor, UIColor.clear.cgColor]
            gradientLayer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
            gradientAnimation.toValue = gradientLayer.colors
            gradientAnimation.duration = 0.25
            gradientAnimation.isRemovedOnCompletion = true
            gradientAnimation.fillMode = .forwards

            // MARK: set state
            if let state = state {
                let enabled = state.on == true
                cell.lightSwitch.isEnabled = true
                cell.lightSwitch.backgroundColor = !enabled ? nil : UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.15)
                cell.brightnessSlider.value = Float(state.bri ?? 127)
                cell.brightnessSlider.isEnabled = true
                cell.brightnessSlider.isHidden = !enabled
                cell.lightSwitch.isOn = enabled
            } else {
                cell.lightSwitch.isEnabled = false
                cell.brightnessSlider.isEnabled = false
                cell.brightnessSlider.isHidden = true
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

                gradientLayer.colors = newColors
                gradientAnimation.toValue = gradientLayer.colors
            }

            cell.layer.add(gradientAnimation, forKey: nil)
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
