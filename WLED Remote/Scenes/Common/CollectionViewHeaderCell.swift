//
//  CollectionViewHeaderCell.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/13/22.
//

import Foundation
import UIKit

class CollectionViewHeaderCell: UICollectionReusableView {
    let label = UILabel().then {
        $0.numberOfLines = 0
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.tintColor = .darkGray
    }

    var title = ""

    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(text: String, accessory: UIView? = nil) {
        label.text = text

        if let view = accessory {
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
                view.widthAnchor.constraint(equalTo: heightAnchor),
                view.heightAnchor.constraint(equalTo: view.widthAnchor),
                view.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }
    }
}
