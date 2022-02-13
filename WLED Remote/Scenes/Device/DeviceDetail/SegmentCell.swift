//
//  SegmentCell.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/14/22.
//

import UIKit
import RxSwift
import RxCocoa

class SegmentCell: UICollectionViewCell {
    static var identifier = "segment-cell"

    // MARK: - Rx

    private var dispose = DisposeBag()

    // MARK: - Views

    let nameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 15)
    }

    let onSwitch = UISwitch().then {
        $0.onTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.20)
        $0.tintColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)
        $0.layer.cornerRadius = 16
        $0.isOn = false
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

        let deviceInfoStackView = UIStackView(arrangedSubviews: [nameLabel]).then {
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
        }

        contentView.addSubview(animatableStackView)

        animatableStackView.do {
            $0.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        }
    }

    override func prepareForReuse() {
        dispose = DisposeBag()
        onSwitch.isOn = false
        nameLabel.textColor = .label
    }

    func bind(_ viewModel: SegmentItemViewModel) {
        let input = SegmentItemViewModel.Input(
            loadTrigger: Driver.just(()),
            on: onSwitch.rx.value.changed.asDriver()
        )

        let output = viewModel.transform(input: input, disposeBag: dispose)

        output.$id
            .asDriver()
            .map({ "Segment \($0)" })
            .drive(nameLabel.rx.text)
            .disposed(by: dispose)

        output.$on
            .asDriver()
            .drive(onSwitch.rx.value)
            .disposed(by: dispose)

        Driver.combineLatest(output.$on.asDriver(), output.$color.asDriver())
            .map { (on: $0.0, color: $0.1) }
            .drive(animateGradient)
            .disposed(by: dispose)
    }

    private var animateGradient: Binder<(on: Bool, color: [Int])> {
        Binder(self) { cell, state in
            var backgroundColors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
            var tintColor = UIColor.label

            if state.on {
                var newColors = [UIColor(red: state.color[0],
                                        green: state.color[1],
                                        blue: state.color[2]).cgColor]

                if newColors.count == 1 {
                    newColors.append(newColors[0])
                }

                backgroundColors = newColors

                if let first = newColors.first {
                    let color = UIColor(cgColor: first)
                    tintColor = color.isLight ? .black : .white
                }
            }

            // Set colors to background navigation

            if let gradientLayer = cell.layer as? CAGradientLayer {
                gradientLayer.gradientChangeAnimation(backgroundColors, animate: true)
            }

            // Animate colors on changed

            UIView.animate(withDuration: 0.2) {
                cell.nameLabel.textColor = tintColor
            }
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
