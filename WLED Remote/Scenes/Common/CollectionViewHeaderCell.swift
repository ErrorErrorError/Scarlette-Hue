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
        $0.font = UIFont.boldSystemFont(ofSize: 12)
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

    func bind(text: String) {
        label.text = text
    }
}
