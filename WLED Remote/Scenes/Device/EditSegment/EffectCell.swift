//
//  EffectCell.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/28/21.
//

import UIKit
import Then

class EffectCell: UICollectionViewCell {
    static let identifier = "effect-cell"

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override var isSelected: Bool {
        didSet {
            let newColor = isSelected ? UIColor.blue.cgColor : UIColor.clear.cgColor
            titleLabel.layer.borderWidth = 2
            titleLabel.layer.borderColor = newColor
        }
    }

    let titleLabel = LabelInset().then {
        $0.backgroundColor = .systemGroupedBackground
        $0.textEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        $0.layer.cornerRadius = 16
        $0.font = .boldSystemFont(ofSize: 14)
        $0.clipsToBounds = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .contentOverSystemBackground
        layer.cornerRadius = 18

        addSubview(titleLabel)
        subviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })

        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(_ item: EffectItemViewModel) {
        titleLabel.text = item.title
    }
}

// MARK: Animation on highlight
extension EffectCell {
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
