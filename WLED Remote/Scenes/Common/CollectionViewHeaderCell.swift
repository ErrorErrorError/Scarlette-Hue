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
    }

    var title = ""

    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 0),
            label.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: 0),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(text: String) {
        label.text = text
    }
}
