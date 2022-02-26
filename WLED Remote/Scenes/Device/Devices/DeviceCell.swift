//
//  DeviceCell.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/13/21.
//

import UIKit
import RxSwift
import RxCocoa
import WLEDClient

class DeviceCell: UICollectionViewCell {
    static var identifier = "device-cell"

    // MARK: - Rx

    private var dispose = DisposeBag()

    // MARK: - Views

    let nameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 18)
        $0.text = "WLED"
    }

    let connectionLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 12)
        $0.textColor = .secondaryLabel
        $0.text = "Connecting"
    }

    let onSwitch = UISwitch().then {
        $0.onTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.20)
        $0.tintColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)
        $0.layer.cornerRadius = 16
        $0.isOn = false
        $0.isEnabled = false
    }

    let animatableStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alignment = .fill
        $0.distribution = .fill
        $0.axis = .vertical
    }

    override public class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let cornerRadius: CGFloat = 30 / 2
        backgroundColor = .contentOverSystemBackground

        layer.do {
            $0.cornerRadius = cornerRadius
            $0.masksToBounds = false
            $0.cornerCurve = .circular
            $0.shadowRadius = 8.0
            $0.shadowOpacity = 0.10
            $0.shadowColor = UIColor.black.cgColor
            $0.shadowOffset = CGSize(width: 0, height: 5)
        }

        if let gradientLayer = layer as? CAGradientLayer {
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        }

        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        let inset: CGFloat = 24

        let deviceInfoStackView = UIStackView(arrangedSubviews: [nameLabel, connectionLabel]).then {
            $0.distribution = .fill
            $0.alignment = .leading
            $0.axis = .vertical
            $0.spacing = 2
        }

        let deviceStateStackView = UIStackView(arrangedSubviews: [deviceInfoStackView, onSwitch]).then {
            $0.spacing = inset
            $0.distribution = .fill
            $0.alignment = .center
            $0.isLayoutMarginsRelativeArrangement = true
            $0.directionalLayoutMargins = .init(top: 20, leading: inset, bottom: 20, trailing: inset)
        }

        animatableStackView.do {
            $0.addArrangedSubview(deviceStateStackView)
//            $0.addArrangedSubview(brightnessSlider)
        }

        contentView.addSubview(animatableStackView)

        animatableStackView.do {
            $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        }
    }

    override func prepareForReuse() {
        dispose = DisposeBag()
        onSwitch.isOn = false
        onSwitch.isEnabled = false
        nameLabel.textColor = .label
        connectionLabel.textColor = .secondaryLabel
        resizeView()
    }

    func bind(_ viewModel: DeviceItemViewModel) {
        let input = DeviceItemViewModel.Input(
            loadTrigger: Driver.just(()),
            on: onSwitch.rx.isOn.changed.asDriver()
        )

        let output = viewModel.transform(input, disposeBag: dispose)

        output.$name
            .asDriver()
            .drive(nameLabel.rx.text)
            .disposed(by: dispose)

        output.$connection
            .asDriver()
            .map({ $0.rawValue })
            .drive(connectionLabel.rx.text)
            .disposed(by: dispose)

        output.$store
            .asDriver()
            .map({ $0?.state })
            .drive(stateBinding)
            .disposed(by: dispose)
    }

    private var stateBinding: Binder<State?> {
        return Binder(self) { cell, state in
            let colors = ColorGradientAnimation.backgroundGradient(from: state)
            let deviceNameTextColor = ColorGradientAnimation
                .textColorForBackgroundGradient(from: state)
            var connectionTextColor = UIColor.secondaryLabel

            if let color = colors.first {
                let darkerColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
                let ligherColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
                connectionTextColor = color.isLight ? darkerColor : ligherColor
            }

            if let state = state {
                let enabled = state.on == true
                cell.onSwitch.isEnabled = true
                cell.onSwitch.backgroundColor = !enabled ? nil : UIColor(red: 90/255,
                                                                         green: 90/255,
                                                                         blue: 90/255,
                                                                         alpha: 0.20)
//                cell.brightnessSlider.value = Float(state.bri ?? 1)
                cell.onSwitch.isOn = enabled
            } else {
                cell.onSwitch.isEnabled = false
                cell.onSwitch.isOn = false
            }
            cell.nameLabel.textColor = deviceNameTextColor
            cell.connectionLabel.textColor = connectionTextColor

            if let gradientLayer = cell.layer as? CAGradientLayer {
                gradientLayer.gradientChangeAnimation(colors.map { $0.cgColor }, animate: true)
            }
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
extension DeviceCell {
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
